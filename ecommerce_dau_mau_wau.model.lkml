connection: "thelook_events_redshift"

include: "/ecommerce_views/order_items.view.lkml"
include: "/ecommerce_views/users.view.lkml"
include: "/ecommerce_views/inventory_items.view.lkml"


view: dau_wau_mau_support {
  derived_table: {
    sql:
select 0 as days_to_add union all
select 1 as days_to_add union all
select 2 as days_to_add union all
select 3 as days_to_add union all
select 4 as days_to_add union all
select 5 as days_to_add union all
select 6 as days_to_add union all
select 7 as days_to_add union all
select 8 as days_to_add union all
select 9 as days_to_add union all
select 10 as days_to_add union all
select 11 as days_to_add union all
select 12 as days_to_add union all
select 13 as days_to_add union all
select 14 as days_to_add union all
select 15 as days_to_add union all
select 16 as days_to_add union all
select 17 as days_to_add union all
select 18 as days_to_add union all
select 19 as days_to_add union all
select 21 as days_to_add union all
select 22 as days_to_add union all
select 23 as days_to_add union all
select 24 as days_to_add union all
select 25 as days_to_add union all
select 26 as days_to_add union all
select 27 as days_to_add union all
select 28 as days_to_add union all
select 29 as days_to_add
    ;;
  }
  dimension: days_to_add {hidden:yes}
  dimension: period_end_date {
    type: date
#     sql: ${order_items.created_date}+${days_to_add} ;;
    sql: ${dau_mau__inputs_view.date_to_use__input_field}+${days_to_add} ;;
  }

  dimension: appeared_on_period_end_date {
    hidden: yes
    type: yesno
    sql: ${days_to_add}=0 ;;
  }
  dimension: appeared_within_week_of_end_date {
    hidden: yes
    type: yesno
    sql: ${days_to_add}<7 ;;
  }
  dimension: appeared_within_30_days {
    hidden: yes
    type: yesno
    sql: ${days_to_add}<30 ;;
  }
  measure: dau {
    type: count_distinct
#     sql: ${order_items.user_id} ;;
    sql: ${dau_mau__inputs_view.user_id__input_field} ;;
    filters: [appeared_on_period_end_date: "Yes"]
  }
  measure: wau {
    type: count_distinct
#     sql: ${order_items.user_id} ;;
    sql: ${dau_mau__inputs_view.user_id__input_field} ;;
    filters: [appeared_within_week_of_end_date: "Yes"]
  }
  measure: mau {
    type: count_distinct
#     sql: ${order_items.user_id} ;;
    sql: ${dau_mau__inputs_view.user_id__input_field} ;;
    filters: [appeared_within_30_days: "Yes"]
  }
}

# explore: order_items_dau_wau_mau {
#   view_name: order_items
#   fields:
#     [ALL_FIELDS*,
#     -order_items.created_time,-order_items.created_date,-order_items.created_week,-order_items.created_month,-order_items.created_quarter,-order_items.created_year
#     ]
#   join: max_date_view {
#     type:cross
#     relationship: one_to_one
#   }
#   join: dau_wau_mau_support {
#     #type: cross # use left outer to exclude users getting couted as active beyond the last activity date
#     type: left_outer
#     sql_on: ${dau_wau_mau_support.period_end_date}<${max_date_view.max_date} ;;
#     relationship: one_to_one
#   }
# }
view: dau_wau_mau_explore_to_be_extended {}#dummy base view
explore: dau_wau_mau_explore_to_be_extended {
  extension: required
  join: dau_mau__inputs_view {sql:;;relationship:one_to_one}
  join: dau_wau_mau_support {
#     type: cross # use left outer to exclude users getting couted as active beyond the last activity date
    type: left_outer
    sql_on: ${dau_wau_mau_support.period_end_date}<(select max(${dau_mau__inputs_view.date_to_use__input_field})from ${dau_mau__inputs_view.date_to_uses_sql_table_name__input_field}) and {%condition dau_wau_mau_support.period_end_date%}${dau_mau__inputs_view.date_to_use__input_field}+30{%endcondition%}  ;;
    relationship: one_to_one
  }
}

####################################
##DAU WAU MAU TINY TEMPLATES VERSION
### 1) Fill in dau_mau__inputs_view's sql fields with the appropriate fields from your explore. Append explore name for uniqueness
view: dau_mau__inputs_view__order_items_explore {
  dimension: date_to_use__input_field {sql:${order_items.created_date};;hidden:yes}
  dimension: date_to_uses_sql_table_name__input_field {sql:${order_items.SQL_TABLE_NAME};;hidden:yes}
  dimension: user_id__input_field {sql:${order_items.user_id};;hidden:yes}
}

#2) Use in a normal explore by adding to extends
#3) Override the inherited dau_mau__inputs_view to point to your version of the inputs view defined above
#4) Should probably exclude original date fields to avoid confusion
explore: order_items__with_dau_wau_mau_extension {
  view_name: order_items
  extends: [dau_wau_mau_explore_to_be_extended]#2
  join: dau_mau__inputs_view {from:dau_mau__inputs_view__order_items_explore}#3
  fields:[ALL_FIELDS*,-order_items.created_time,-order_items.created_date,-order_items.created_week,-order_items.created_month,-order_items.created_quarter,-order_items.created_year]#4

  #other joins as normal
  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${order_items.user_id}=${users.id} ;;
  }
  join: inventory_items {
    type: left_outer
    relationship: many_to_one
    sql_on: ${order_items.inventory_item_id}=${inventory_items.id} ;;
  }
}


########Another implementation on events data
include: "/**/events.view.lkml"
view: dau_mau__inputs_view__events_explore {
  dimension: date_to_use__input_field {sql:${events.created_date};;hidden:yes}
  dimension: date_to_uses_sql_table_name__input_field {sql:${events.SQL_TABLE_NAME};;hidden:yes}
  dimension: user_id__input_field {sql:${events.user_id};;hidden:yes}
}
explore: events__with_dau_wau_mau_extension {
  view_name: events
  extends: [dau_wau_mau_explore_to_be_extended]
  join: dau_mau__inputs_view {from:dau_mau__inputs_view__events_explore}
  fields:[ALL_FIELDS*,-events.created_time,-events.created_date,-events.created_week,-events.created_month,-events.created_quarter,-events.created_year]
}

