import '../models/directorate_reporting_framework.dart';
import '../models/reporting_metric_field.dart';

/// Reporting & metrics per directorate. IDs match [kSeedUnitsByDirectorate].
/// Directorates not in this map use [buildFallbackReportingFramework].
final Map<String, DirectorateReportingFramework> kReportingFrameworkCatalog = {
  'missions_evangelism': DirectorateReportingFramework(
    unitHeadFieldsByUnitId: {
      'me_u1': const [
        ReportingMetricField(
          id: 'locations_reached',
          label: 'Number of locations reached (street outreach)',
          input: ReportingMetricInput.wholeNumber,
        ),
        ReportingMetricField(
          id: 'souls_won',
          label: 'Total souls won',
          input: ReportingMetricInput.wholeNumber,
        ),
        ReportingMetricField(
          id: 'contacts_captured',
          label: 'Total contact details captured',
          input: ReportingMetricInput.wholeNumber,
        ),
      ],
      'me_u2': const [
        ReportingMetricField(
          id: 'rural_stations_needs',
          label: 'Rural stations — current needs (list main gaps)',
          input: ReportingMetricInput.multiline,
        ),
        ReportingMetricField(
          id: 'household_visits',
          label: 'Number of household visits completed',
          input: ReportingMetricInput.wholeNumber,
        ),
        ReportingMetricField(
          id: 'community_leader_engagement',
          label: 'Community leader engagement (who reached; follow-up)',
          input: ReportingMetricInput.multiline,
        ),
      ],
      'me_u3': const [
        ReportingMetricField(
          id: 'venue_readiness_pct',
          label: 'Venue readiness % (pre-event checklist)',
          input: ReportingMetricInput.decimal,
        ),
        ReportingMetricField(
          id: 'total_attendance',
          label: 'Total attendance count (event / crusade)',
          input: ReportingMetricInput.wholeNumber,
        ),
        ReportingMetricField(
          id: 'sound_technical_status',
          label: 'Sound & technical status (issues resolved / open)',
          input: ReportingMetricInput.multiline,
        ),
      ],
      'me_u4': const [
        ReportingMetricField(
          id: 'converts_called_48h',
          label: 'Number of converts contacted within 48 hours',
          input: ReportingMetricInput.wholeNumber,
        ),
        ReportingMetricField(
          id: 'converts_to_discipleship',
          label: 'Number of converts handed to Discipleship',
          input: ReportingMetricInput.wholeNumber,
        ),
      ],
    },
    unitHeadByUnitId: {
      'me_u1': const [
        'Street outreach — number of locations reached this week.',
        'Total souls won (record actual counts).',
        'Total contact details captured (for follow-up).',
      ],
      'me_u2': const [
        'Rural stations — current needs (list main gaps).',
        'Number of household visits completed.',
        'Community leader engagement status (who was reached; follow-up).',
      ],
      'me_u3': const [
        'Venue readiness % (pre-event checklist).',
        'Total attendance count (event / crusade).',
        'Sound and technical status report (issues resolved / open).',
      ],
      'me_u4': const [
        'Number of converts contacted within 48 hours.',
        'Number of converts successfully handed to Discipleship (integration).',
      ],
    },
    managerTactical: const [
      'Logistics status: fuel/transport usage for the week; personnel deployment (active vs. absent).',
      'Conversion rate: % of souls won vs. souls successfully integrated into the system.',
      'Operational hitches: barriers to evangelism (weather, security, equipment failure, etc.).',
    ],
    directorStrategic: const [
      'Growth trend: souls won this month vs. previous month (comparison).',
      'National reach: list new territories/communities entered.',
      'Budget vs. impact: total funds spent vs. spiritual results achieved (narrative + key numbers).',
    ],
  ),
  'intercession_prayer': DirectorateReportingFramework(
    unitHeadFieldsByUnitId: {
      'ip_u1': const [
        ReportingMetricField(
          id: 'session_log',
          label: 'Daily prayer sessions — times started/ended (week summary)',
          input: ReportingMetricInput.multiline,
        ),
        ReportingMetricField(
          id: 'intercessor_attendance',
          label: 'Attendance of intercessors (count or roster note)',
          input: ReportingMetricInput.wholeNumber,
        ),
      ],
      'ip_u2': const [
        ReportingMetricField(
          id: 'new_intercessors_db',
          label: 'New intercessors added to national database',
          input: ReportingMetricInput.wholeNumber,
        ),
      ],
      'ip_u3': const [
        ReportingMetricField(
          id: 'prophetic_content',
          label: 'Key prophetic words/visions (summary or transcript)',
          input: ReportingMetricInput.multiline,
        ),
      ],
      'ip_u4': const [
        ReportingMetricField(
          id: 'fast_participants',
          label: 'Members participating in national fast',
          input: ReportingMetricInput.wholeNumber,
        ),
      ],
    },
    unitHeadByUnitId: {
      'ip_u1': const [
        'Daily prayer session log: time started / ended (per day or week summary).',
        'Attendance of intercessors (counts or roster summary).',
      ],
      'ip_u2': const [
        'Number of new intercessors added to the national database.',
      ],
      'ip_u3': const [
        'Transcript or summary of key prophetic words/visions received during sessions.',
      ],
      'ip_u4': const [
        'Number of members participating in the national fast.',
      ],
    },
    managerTactical: const [
      'Roster compliance: gaps in the 24/7 prayer chain (who missed their shift — summarize).',
      'Spiritual climate: summary of “spiritual intelligence” for the Senior Resident Pastor.',
    ],
    directorStrategic: const [
      'Prophetic alignment: how prayer themes align with upcoming national events.',
      'Spiritual coverage: status of “firewalls” around the ministry’s major projects.',
    ],
  ),
  'programs_publicity': DirectorateReportingFramework(
    unitHeadFieldsByUnitId: {
      'pp_u1': const [
        ReportingMetricField(
          id: 'order_of_service_status',
          label: 'Order of Service scripts — progress (drafted/approved; pending items)',
          input: ReportingMetricInput.multiline,
        ),
      ],
      'pp_u2': const [
        ReportingMetricField(
          id: 'calendar_clashes',
          label: 'Upcoming dates across directorates — list & clash flags',
          input: ReportingMetricInput.multiline,
        ),
      ],
      'pp_u3': const [
        ReportingMetricField(
          id: 'ad_spend_total',
          label: 'Ad spend total (currency)',
          input: ReportingMetricInput.decimal,
        ),
        ReportingMetricField(
          id: 'social_impressions',
          label: 'Social media impressions',
          input: ReportingMetricInput.wholeNumber,
        ),
        ReportingMetricField(
          id: 'social_likes',
          label: 'Social media likes / engagements',
          input: ReportingMetricInput.wholeNumber,
        ),
        ReportingMetricField(
          id: 'flyers_distributed',
          label: 'Flyers or materials distributed',
          input: ReportingMetricInput.wholeNumber,
        ),
      ],
      'pp_u4': const [
        ReportingMetricField(
          id: 'last_program_attendance',
          label: 'Attendance — last program',
          input: ReportingMetricInput.wholeNumber,
        ),
        ReportingMetricField(
          id: 'post_program_feedback',
          label: 'Post-program feedback summary',
          input: ReportingMetricInput.multiline,
        ),
      ],
    },
    unitHeadByUnitId: {
      'pp_u1': const [
        'Order of Service scripts — progress (drafted / approved; list items pending).',
      ],
      'pp_u2': const [
        'Upcoming dates across all 24 directorates — list and flag any clashes.',
      ],
      'pp_u3': const [
        'Ad spend report (totals).',
        'Social media reach: impressions, likes (or platform equivalents).',
        'Number of flyers or materials distributed.',
      ],
      'pp_u4': const [
        'Attendance figures for the last program.',
        'Post-program feedback summary.',
      ],
    },
    managerTactical: const [
      'Project countdown: % readiness for the next major national program.',
      'Media performance: which publicity channel (radio, TV, web) brought the most engagement.',
    ],
    directorStrategic: const [
      'Brand health: summary of public perception of the ministry.',
      'Program effectiveness: ROI of major events (attendance and souls, qualitative + numbers).',
    ],
  ),
  'finance_treasury_supply': DirectorateReportingFramework(
    unitHeadFieldsByUnitId: {
      'fts_u1': const [
        ReportingMetricField(
          id: 'ledger_balance',
          label: 'Ledger balance (as of report date)',
          input: ReportingMetricInput.singleLine,
        ),
        ReportingMetricField(
          id: 'unposted_transactions',
          label: 'Unposted transactions (references / descriptions)',
          input: ReportingMetricInput.multiline,
        ),
      ],
      'fts_u2': const [
        ReportingMetricField(
          id: 'tithes_offerings_seeds',
          label: 'Tithes, offerings, seeds collected (break down totals)',
          input: ReportingMetricInput.multiline,
        ),
        ReportingMetricField(
          id: 'deposit_reference',
          label: 'Bank deposit confirmation / slip reference',
          input: ReportingMetricInput.singleLine,
        ),
      ],
      'fts_u3': const [
        ReportingMetricField(
          id: 'quotes_received_count',
          label: 'Quotes received for pending requests (count)',
          input: ReportingMetricInput.wholeNumber,
        ),
        ReportingMetricField(
          id: 'vendor_performance',
          label: 'Vendor performance ratings (brief)',
          input: ReportingMetricInput.multiline,
        ),
      ],
      'fts_u4': const [
        ReportingMetricField(
          id: 'stock_levels',
          label: 'Stock levels of key consumables',
          input: ReportingMetricInput.multiline,
        ),
        ReportingMetricField(
          id: 'damaged_lost_assets',
          label: 'Damaged or lost assets (list)',
          input: ReportingMetricInput.multiline,
        ),
      ],
    },
    unitHeadByUnitId: {
      'fts_u1': const [
        'Daily ledger balance (as of report date).',
        'List of unposted transactions (reference / description).',
      ],
      'fts_u2': const [
        'Tithes, offerings, seeds collected (separate totals where applicable).',
        'Bank deposit slips: digital upload reference / confirmation.',
      ],
      'fts_u3': const [
        'List of quotes received for pending procurement requests.',
        'Vendor performance ratings (brief).',
      ],
      'fts_u4': const [
        'Current stock levels of key consumables.',
        'List of damaged or lost assets.',
      ],
    },
    managerTactical: const [
      'Budget monitoring: % of budget used for the month.',
      'Cash flow status: immediate liquidity available for operations.',
      'Audit readiness: confirmation that vouchers and receipts are filed correctly.',
    ],
    directorStrategic: const [
      'Financial health: revenue vs. expenditure for the national body (summary).',
      'Asset growth: value of new assets acquired vs. depreciated assets.',
    ],
  ),
  'security_defense': DirectorateReportingFramework(
    unitHeadPhotoEvidenceRecommended: true,
    unitHeadFieldsByUnitId: {
      'sd_u1': const [
        ReportingMetricField(
          id: 'vip_movement_log',
          label: 'VIP movement log (G.O./SRP) — schedule & deviations',
          input: ReportingMetricInput.multiline,
        ),
        ReportingMetricField(
          id: 'travel_threat_assessment',
          label: 'Threat assessment for upcoming travel',
          input: ReportingMetricInput.multiline,
        ),
      ],
      'sd_u2': const [
        ReportingMetricField(
          id: 'incident_count',
          label: 'Incidents logged (count)',
          input: ReportingMetricInput.wholeNumber,
        ),
        ReportingMetricField(
          id: 'incident_log_detail',
          label: 'Incident log detail (thefts, disruptions, arrests; refs)',
          input: ReportingMetricInput.multiline,
        ),
        ReportingMetricField(
          id: 'cctv_status',
          label: 'CCTV status (e.g. zones online/total)',
          input: ReportingMetricInput.singleLine,
        ),
      ],
      'sd_u3': const [
        ReportingMetricField(
          id: 'pre_event_checklist_pct',
          label: 'Pre-event security checklist % complete',
          input: ReportingMetricInput.decimal,
        ),
        ReportingMetricField(
          id: 'event_incidents',
          label: 'Program/event incidents & resolutions',
          input: ReportingMetricInput.multiline,
        ),
      ],
      'sd_u4': const [
        ReportingMetricField(
          id: 'intelligence_brief',
          label: 'External security intelligence affecting ministry',
          input: ReportingMetricInput.multiline,
        ),
        ReportingMetricField(
          id: 'risk_register_updates',
          label: 'Risk register (new / closed items)',
          input: ReportingMetricInput.multiline,
        ),
      ],
    },
    unitHeadByUnitId: {
      'sd_u1': const [
        'VIP — daily movement log of the G.O./SRP (concise schedule + deviations).',
        'Threat assessment for upcoming travel.',
      ],
      'sd_u2': const [
        'Crowd/facility — incident log (thefts, disruptions, arrests; reference numbers if any).',
        'CCTV system status: online/offline by zone or summary.',
      ],
      'sd_u3': const [
        'Program/event security — pre-event checklist status; incidents during events.',
        'Photo evidence: upload incident or site photos where policy allows.',
      ],
      'sd_u4': const [
        'Security intelligence — external briefing notes affecting ministry (communal/national).',
        'Risk register updates (new / closed items).',
      ],
    },
    managerTactical: const [
      'Personnel readiness: deployment map for headquarters and branches (summary).',
      'Intelligence summary: external security threats impacting the ministry.',
    ],
    directorStrategic: const [
      'Safety rating: monthly security score for EBOMIM facilities (method as defined by HQ).',
      'Inter-agency relations: collaboration with Police, DSS, Civil Defense (status).',
    ],
  ),
  'electricity_infrastructure_facilities': DirectorateReportingFramework(
    unitHeadPhotoEvidenceRecommended: true,
    unitHeadFieldsByUnitId: {
      'eif_u1': const [
        ReportingMetricField(
          id: 'generator_run_hours',
          label: 'Generator run-hours',
          input: ReportingMetricInput.decimal,
        ),
        ReportingMetricField(
          id: 'fuel_consumed_liters',
          label: 'Diesel / gas consumption (liters)',
          input: ReportingMetricInput.decimal,
        ),
        ReportingMetricField(
          id: 'solar_battery_status',
          label: 'Solar / battery / inverter status',
          input: ReportingMetricInput.multiline,
        ),
      ],
      'eif_u2': const [
        ReportingMetricField(
          id: 'repairs_completed_count',
          label: 'Completed repairs (count)',
          input: ReportingMetricInput.wholeNumber,
        ),
        ReportingMetricField(
          id: 'pending_maintenance',
          label: 'Pending maintenance requests',
          input: ReportingMetricInput.multiline,
        ),
        ReportingMetricField(
          id: 'photo_references',
          label: 'Photo evidence references (before/after)',
          input: ReportingMetricInput.singleLine,
        ),
      ],
      'eif_u3': const [
        ReportingMetricField(
          id: 'work_orders_completed',
          label: 'Work orders completed',
          input: ReportingMetricInput.wholeNumber,
        ),
        ReportingMetricField(
          id: 'work_orders_open',
          label: 'Work orders open',
          input: ReportingMetricInput.wholeNumber,
        ),
        ReportingMetricField(
          id: 'utility_outages',
          label: 'Utility outages & resolutions',
          input: ReportingMetricInput.multiline,
        ),
      ],
      'eif_u4': const [
        ReportingMetricField(
          id: 'equipment_breakdowns',
          label: 'Equipment breakdowns (count)',
          input: ReportingMetricInput.wholeNumber,
        ),
        ReportingMetricField(
          id: 'spare_parts_stock',
          label: 'Spare parts / critical stock status',
          input: ReportingMetricInput.multiline,
        ),
      ],
    },
    unitHeadByUnitId: {
      'eif_u1': const [
        'Power — generator run-hours; diesel/gas consumption log.',
        'Solar battery health / inverter status if applicable.',
      ],
      'eif_u2': const [
        'Civil — completed repairs (plumbing, masonry, paint) with locations.',
        'Pending maintenance requests list.',
        'Photo evidence: before/after for completed repairs (recommended).',
      ],
      'eif_u3': const [
        'Facility maintenance — work orders completed vs. open.',
        'Utility outages and resolutions (water, waste, HVAC as relevant).',
      ],
      'eif_u4': const [
        'Assets & equipment — maintenance due; breakdowns; spare parts stock.',
      ],
    },
    managerTactical: const [
      'Project progress: % completion of ongoing construction / civil works.',
      'Maintenance compliance: % of scheduled preventative maintenance completed.',
    ],
    directorStrategic: const [
      'Infrastructure value: summary of structural improvements to EBOMIM real estate.',
      'Energy efficiency: power cost savings (grid vs. generator vs. solar narrative + figures).',
    ],
  ),
  'state_ministry': DirectorateReportingFramework(
    unitHeadFieldsByUnitId: {
      'state_ministry': const [
        ReportingMetricField(
          id: 'attendance_count',
          label: 'Total Attendance',
          input: ReportingMetricInput.wholeNumber,
        ),
        ReportingMetricField(
          id: 'offering_total',
          label: 'Total Offering (Amount)',
          input: ReportingMetricInput.decimal,
        ),
        ReportingMetricField(
          id: 'testimonies_summary',
          label: 'Testimonies & Ministry Updates',
          input: ReportingMetricInput.multiline,
        ),
      ],
    },
    unitHeadByUnitId: {
      'state_ministry': const [
        'Total attendance for the state ministry events.',
        'Total offering collected (currency).',
        'Summary of testimonies and general ministry updates.',
      ],
    },
    managerTactical: const [],
    directorStrategic: const [],
  ),
};
