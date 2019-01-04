connection: "thelook_events_redshift"

include: "*.view.lkml"         # include all views in this project
include: "DATAGROUPS.view.lkml"
explore: session_summary {
  join: events {
    type: left_outer
    relationship: one_to_many
    sql_on: ${session_summary.pk_session_id}=${events.session_id} ;;
  }
}
