view: events {
#   sql_table_name: public.events ;;
derived_table: {
  sql:
with step1 as
(
select
row_number() over(partition by session_id order by sequence_number desc) as sequence_reverse
,datediff(seconds,lag(created_at,sequence_number-1) over (partition by session_id order by session_id, sequence_number),created_at) as time_from_first_event
,datediff(seconds,lag(created_at,1) over (partition by session_id order by session_id, sequence_number),created_at) as time_from_previous_event
,datediff(seconds,created_at,lead(created_at,1) over (partition by session_id order by session_id, sequence_number)) as time_from_next_event
,* from public.events
),
step2 as
(
select
datediff(seconds,created_at,lead(created_at,cast(sequence_reverse as integer)-1)  over (partition by session_id order by session_id, sequence_number)) as time_from_last_event
,* from step1
)

select * from step2
;;
}

  dimension: sequence_reverse {type:number}
  dimension: time_from_first_event {type:number}
  dimension: time_from_first_event_tier {type:tier sql:${time_from_first_event};; tiers:[20,40,60,80,100,120]}
  dimension: time_from_last_event {type:number}
  dimension: time_from_previous_event {type:number}
  dimension: time_from_next_event {type:number}

  dimension: pk_event_id {
    group_label: "system & duplicate fields"
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: id {
    group_label: "system & duplicate fields"
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: browser {
    type: string
    sql: ${TABLE}.browser ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
  }

  dimension_group: created {
    convert_tz: no
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension: event_type {
    type: string
    sql: ${TABLE}.event_type ;;
  }

  dimension: ip_address {
    type: string
    sql: ${TABLE}.ip_address ;;
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}.latitude ;;
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}.longitude ;;
  }

  dimension: os {
    type: string
    sql: ${TABLE}.os ;;
  }

  dimension: sequence_number {
    type: number
    sql: ${TABLE}.sequence_number ;;
  }

  dimension: session_id {
    type: string
    sql: ${TABLE}.session_id ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension: traffic_source {
    type: string
    sql: ${TABLE}.traffic_source ;;
  }

  dimension: uri {
    type: string
    sql: ${TABLE}.uri ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: zip {
    type: zipcode
    sql: ${TABLE}.zip ;;
  }

  measure: count {
    type: count
    drill_fields: [id]
  }
}
