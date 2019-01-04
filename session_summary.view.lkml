view: session_summary {
  derived_table: {
    sql:
SELECT
events.session_id,
count(distinct events.user_id) as multi_user_id_check,
min(events.user_id) as user_id,
COUNT(distinct events.id) AS session_events_count,
max(case when event_type= 'Cart' then 1 else 0 end) as session_has_cart_event,
sum(case when event_type= 'Cart' then 1 else 0 end) as session_count_cart_events,
max(case when event_type= 'Purchase' then 1 else 0 end) as session_has_purchase_event,
sum(case when event_type= 'Purchase' then 1 else 0 end) as session_count_purchase_events,
max(sequence_number) as session_last_sequence_number,
min(created_at) as session_first_event,
max(created_at) as session_last_event
FROM public.events  AS events
GROUP BY 1
    ;;
    datagroup_trigger: default_datagroup
    distribution: "session_id"
    sortkeys: ["session_id","user_id","session_first_event"]
  }

  dimension: pk_session_id {
    group_label: "system & duplicate fields"
    primary_key: yes
    sql: ${TABLE}.session_id ;;
  }
  dimension: multi_user_id_check {
    group_label: "system & duplicate fields"
    type: number
  }
  dimension: user_id {
    type: number
  }

  dimension: session_events_count {
    type: number
  }
  measure: total_session_events_count {
    type: sum
    sql: ${session_events_count} ;;
  }
  measure: session_events_count_summary {
    group_label: "summary measures"
    sql: 'count sessions: '||${session_count}||' | min: '||min(${session_events_count})||' | max:'||max(${session_events_count}) ;;
  }

  dimension: session_has_cart_event {
    type: number
  }
  measure: total_session_has_cart_event {
    type: sum
    sql: ${session_has_cart_event} ;;
  }
  measure: session_has_cart_event_summary {
    group_label: "summary measures"
    sql: 'count sessions: '||${session_count}||' | min: '||min(${session_has_cart_event})||' | max:'||max(${session_has_cart_event}) ;;
  }

  dimension: session_count_cart_events {
    type: number
  }
  measure: total_session_count_cart_events {
    type: sum
    sql: ${session_count_cart_events} ;;
  }
  measure: session_session_count_cart_events_summary {
    group_label: "summary measures"
    sql: 'count sessions: '||${session_count}||' | min: '||min(${session_count_cart_events})||' | max:'||max(${session_count_cart_events}) ;;
  }

  dimension: session_has_purchase_event {
    type: number
  }
  measure: total_session_has_purchase_event {
    type: sum
    sql: ${session_has_purchase_event} ;;
  }
  measure: session_session_has_purchase_event_summary {
    group_label: "summary measures"
    sql: 'count sessions: '||${session_count}||' | min: '||min(${session_has_purchase_event})||' | max:'||max(${session_has_purchase_event}) ;;
  }

  dimension: session_count_purchase_events {
    type: number
  }
  measure: total_session_count_purchase_events {
    type: sum
    sql: ${session_count_purchase_events} ;;
  }
  measure: session_session_count_purchase_events_summary {
    group_label: "summary measures"
    sql: 'count sessions: '||${session_count}||' | min: '||min(${session_count_purchase_events})||' | max:'||max(${session_count_purchase_events}) ;;
  }

  dimension: session_last_sequence_number {
    type: number
  }
  measure: total_session_last_sequence_number {
    type: sum
    sql: ${session_last_sequence_number} ;;
  }
  measure: session_session_last_sequence_number_summary {
    group_label: "summary measures"
    sql: 'count sessions: '||${session_count}||' | min: '||min(${session_last_sequence_number})||' | max:'||max(${session_last_sequence_number}) ;;
  }

  dimension_group: session_first_event {
    convert_tz: no
    type: time
    timeframes: [raw,time,date,month,year]
  }

  dimension: session_first_event__raw {
    convert_tz: no
    type: date
    datatype: date
    sql: ${TABLE}.session_first_event ;;
  }

  dimension_group: session_last_event {
    convert_tz: no
    type: time
    timeframes: [raw,time,date,month,year]
  }

  measure: session_count {
    type: count
    filters:{
      field: pk_session_id
      value: "-NULL"
    }
  }
  measure: count_users {
    type: count_distinct
    sql: ${user_id} ;;
  }


}
