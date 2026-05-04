import '../models/unit.dart';

/// Units per directorate — aligned with org structure (Firebase later).
/// Directorate IDs match [kDirectorates] in `directorates.dart`.
final Map<String, List<Unit>> kSeedUnitsByDirectorate = {
  'administration_national_intl': const [
    Unit(
      id: 'ad_u1',
      name: 'National administration office unit',
      directorateId: 'administration_national_intl',
    ),
    Unit(
      id: 'ad_u2',
      name: 'International administration office unit',
      directorateId: 'administration_national_intl',
    ),
    Unit(
      id: 'ad_u3',
      name: 'Human resource and personnel management unit',
      directorateId: 'administration_national_intl',
    ),
    Unit(
      id: 'ad_u4',
      name: 'Records, documentation and compliance unit',
      directorateId: 'administration_national_intl',
    ),
  ],
  'missions_evangelism': const [
    Unit(
      id: 'me_u1',
      name: 'Street and Community Evangelism Unit',
      directorateId: 'missions_evangelism',
    ),
    Unit(
      id: 'me_u2',
      name: 'Missionary and rural outreach unit',
      directorateId: 'missions_evangelism',
    ),
    Unit(
      id: 'me_u3',
      name: 'Crusades and mass evangelism unit',
      directorateId: 'missions_evangelism',
    ),
    Unit(
      id: 'me_u4',
      name: 'Convert care and integration unit',
      directorateId: 'missions_evangelism',
    ),
  ],
  'intercession_prayer': const [
    Unit(
      id: 'ip_u1',
      name: 'National prayer operations unit',
      directorateId: 'intercession_prayer',
    ),
    Unit(
      id: 'ip_u2',
      name: 'Intercessors network and mobilization unit',
      directorateId: 'intercession_prayer',
    ),
    Unit(
      id: 'ip_u3',
      name: 'Prayer bulletins and prophetic intelligence unit',
      directorateId: 'intercession_prayer',
    ),
    Unit(
      id: 'ip_u4',
      name: 'Fasting and consecration unit',
      directorateId: 'intercession_prayer',
    ),
  ],
  'discipleship_mentorship': const [
    Unit(
      id: 'dm_u1',
      name: 'New converts and foundations unit',
      directorateId: 'discipleship_mentorship',
    ),
    Unit(
      id: 'dm_u2',
      name: 'Discipleship pathways and growth unit',
      directorateId: 'discipleship_mentorship',
    ),
    Unit(
      id: 'dm_u3',
      name: 'Mentorship and leadership development unit',
      directorateId: 'discipleship_mentorship',
    ),
    Unit(
      id: 'dm_u4',
      name: 'Cell groups and spiritual communities unit',
      directorateId: 'discipleship_mentorship',
    ),
  ],
  'ministerial_education_training': const [
    Unit(
      id: 'met_provost',
      name: 'Provost: EBOMIM School of Ministry',
      directorateId: 'ministerial_education_training',
    ),
    Unit(
      id: 'met_u1',
      name: 'Curriculum and doctrinal development unit',
      directorateId: 'ministerial_education_training',
    ),
    Unit(
      id: 'met_u2',
      name: 'Missionary and field training unit',
      directorateId: 'ministerial_education_training',
    ),
    Unit(
      id: 'met_u3',
      name: 'Prayer and intercessory training unit',
      directorateId: 'ministerial_education_training',
    ),
    Unit(
      id: 'met_u4',
      name: 'Leadership, character, and ethics unit',
      directorateId: 'ministerial_education_training',
    ),
  ],
  'music_governance_strategy': const [
    Unit(
      id: 'mgs_u1',
      name: 'Worship and praise unit',
      directorateId: 'music_governance_strategy',
    ),
    Unit(
      id: 'mgs_u2',
      name: 'Choir and vocal training unit',
      directorateId: 'music_governance_strategy',
    ),
    Unit(
      id: 'mgs_u3',
      name: 'Instrument and band unit',
      directorateId: 'music_governance_strategy',
    ),
    Unit(
      id: 'mgs_u4',
      name: 'Music composition and content review unit',
      directorateId: 'music_governance_strategy',
    ),
  ],
  'politics_governance': const [
    Unit(
      id: 'pg_u1',
      name: 'Governance intelligence and policy research unit',
      directorateId: 'politics_governance',
    ),
    Unit(
      id: 'pg_u2',
      name: 'Kingdom leadership and public service preparations unit',
      directorateId: 'politics_governance',
    ),
    Unit(
      id: 'pg_u3',
      name: 'Civic engagement and voter education',
      directorateId: 'politics_governance',
    ),
    Unit(
      id: 'pg_u4',
      name: 'Advocacy, justice and public intervention unit',
      directorateId: 'politics_governance',
    ),
  ],
  'research_monitoring_eval': const [
    Unit(
      id: 'rme_u1',
      name: 'Research and strategy development unit',
      directorateId: 'research_monitoring_eval',
    ),
    Unit(
      id: 'rme_u2',
      name: 'Monitoring and field compliance unit',
      directorateId: 'research_monitoring_eval',
    ),
    Unit(
      id: 'rme_u3',
      name: 'Evaluation and performance unit',
      directorateId: 'research_monitoring_eval',
    ),
    Unit(
      id: 'rme_u4',
      name: 'Mobilization and participation unit',
      directorateId: 'research_monitoring_eval',
    ),
  ],
  'finance_treasury_supply': const [
    Unit(
      id: 'fts_u1',
      name: 'Finance and accounts unit',
      directorateId: 'finance_treasury_supply',
    ),
    Unit(
      id: 'fts_u2',
      name: 'Treasury and funds management unit',
      directorateId: 'finance_treasury_supply',
    ),
    Unit(
      id: 'fts_u3',
      name: 'Procurement and purchasing unit',
      directorateId: 'finance_treasury_supply',
    ),
    Unit(
      id: 'fts_u4',
      name: 'Stores, inventory and supply unit',
      directorateId: 'finance_treasury_supply',
    ),
  ],
  'audit_influence': const [
    Unit(
      id: 'ai_u1',
      name: 'Financial accountability',
      directorateId: 'audit_influence',
    ),
    Unit(
      id: 'ai_u2',
      name: 'Administrative compliance',
      directorateId: 'audit_influence',
    ),
    Unit(
      id: 'ai_u3',
      name: 'Risk management',
      directorateId: 'audit_influence',
    ),
    Unit(
      id: 'ai_u4',
      name: 'Ethics and integrity',
      directorateId: 'audit_influence',
    ),
  ],
  'programs_publicity': const [
    Unit(
      id: 'pp_u1',
      name: 'Program design and planning',
      directorateId: 'programs_publicity',
    ),
    Unit(
      id: 'pp_u2',
      name: 'Scheduling and calendar management unit',
      directorateId: 'programs_publicity',
    ),
    Unit(
      id: 'pp_u3',
      name: 'Publicity and announcement unit',
      directorateId: 'programs_publicity',
    ),
    Unit(
      id: 'pp_u4',
      name: 'Program monitoring and feedback unit',
      directorateId: 'programs_publicity',
    ),
  ],
  'inter_ministerial_services': const [
    Unit(
      id: 'ims_u1',
      name: 'Christian bodies liaison unit',
      directorateId: 'inter_ministerial_services',
    ),
    Unit(
      id: 'ims_u2',
      name: 'Partnership and collaboration unit',
      directorateId: 'inter_ministerial_services',
    ),
    Unit(
      id: 'ims_u3',
      name: 'Protocol and official representation unit',
      directorateId: 'inter_ministerial_services',
    ),
    Unit(
      id: 'ims_u4',
      name: 'Conflict resolution and advisory unit',
      directorateId: 'inter_ministerial_services',
    ),
  ],
  'women_affairs': const [
    Unit(
      id: 'wa_u1',
      name: 'Women discipleship and spiritual growth',
      directorateId: 'women_affairs',
    ),
    Unit(
      id: 'wa_u2',
      name: 'Women leadership and capacity development unit',
      directorateId: 'women_affairs',
    ),
    Unit(
      id: 'wa_u3',
      name: 'Women welfare and family support unit',
      directorateId: 'women_affairs',
    ),
    Unit(
      id: 'wa_u4',
      name: 'Women mobilization and outreach unit',
      directorateId: 'women_affairs',
    ),
  ],
  'intl_affairs_partnership': const [
    Unit(
      id: 'iap_u1',
      name: 'International missions and outreach unit',
      directorateId: 'intl_affairs_partnership',
    ),
    Unit(
      id: 'iap_u2',
      name: 'Global partnership and alliances unit',
      directorateId: 'intl_affairs_partnership',
    ),
    Unit(
      id: 'iap_u3',
      name: 'International branches and diaspora coordination unit',
      directorateId: 'intl_affairs_partnership',
    ),
    Unit(
      id: 'iap_u4',
      name: 'International protocol, compliance, and liaison unit',
      directorateId: 'intl_affairs_partnership',
    ),
  ],
  'youth_affairs_social': const [
    Unit(
      id: 'yas_u1',
      name: 'Youth discipleship and spiritual formation unit',
      directorateId: 'youth_affairs_social',
    ),
    Unit(
      id: 'yas_u2',
      name: 'Youth leadership and capacity development unit',
      directorateId: 'youth_affairs_social',
    ),
    Unit(
      id: 'yas_u3',
      name: 'Youth social services and empowerment unit',
      directorateId: 'youth_affairs_social',
    ),
    Unit(
      id: 'yas_u4',
      name: 'Youth mobilization and outreach unit',
      directorateId: 'youth_affairs_social',
    ),
  ],
  'hospitality_welfare_humanitarian': const [
    Unit(
      id: 'hwh_u1',
      name: 'Hospitality and guest services unit',
      directorateId: 'hospitality_welfare_humanitarian',
    ),
    Unit(
      id: 'hwh_u2',
      name: 'Staff members and welfare unit',
      directorateId: 'hospitality_welfare_humanitarian',
    ),
    Unit(
      id: 'hwh_u3',
      name: 'Humanitarian outreach and relief unit',
      directorateId: 'hospitality_welfare_humanitarian',
    ),
    Unit(
      id: 'hwh_u4',
      name: 'Volunteers and care support unit',
      directorateId: 'hospitality_welfare_humanitarian',
    ),
  ],
  'security_defense': const [
    Unit(
      id: 'sd_u1',
      name: 'VIP and leadership protection unit',
      directorateId: 'security_defense',
    ),
    Unit(
      id: 'sd_u2',
      name: 'Facility and infrastructure security unit',
      directorateId: 'security_defense',
    ),
    Unit(
      id: 'sd_u3',
      name: 'Programs and event security unit',
      directorateId: 'security_defense',
    ),
    Unit(
      id: 'sd_u4',
      name: 'Security intelligence and risk assessment unit',
      directorateId: 'security_defense',
    ),
  ],
  'communication_transport_logistics': const [
    Unit(
      id: 'ctl_u1',
      name: 'Media, ICT, digital communications unit',
      directorateId: 'communication_transport_logistics',
    ),
    Unit(
      id: 'ctl_u2',
      name: 'Sound, publication and printing unit',
      directorateId: 'communication_transport_logistics',
    ),
    Unit(
      id: 'ctl_u3',
      name: 'Transport and fleet management unit',
      directorateId: 'communication_transport_logistics',
    ),
    Unit(
      id: 'ctl_u4',
      name: 'Logistics and equipment support unit',
      directorateId: 'communication_transport_logistics',
    ),
  ],
  'health_services_infra': const [
    Unit(
      id: 'hsi_u1',
      name: 'Clinical service and first aid unit',
      directorateId: 'health_services_infra',
    ),
    Unit(
      id: 'hsi_u2',
      name: 'Medical outreach and community health unit',
      directorateId: 'health_services_infra',
    ),
    Unit(
      id: 'hsi_u3',
      name: 'Preventive health and wellness education unit',
      directorateId: 'health_services_infra',
    ),
    Unit(
      id: 'hsi_u4',
      name: 'Medical logistics and compliance unit',
      directorateId: 'health_services_infra',
    ),
  ],
  'electricity_infrastructure_facilities': const [
    Unit(
      id: 'eif_u1',
      name: 'Electricity and power systems unit',
      directorateId: 'electricity_infrastructure_facilities',
    ),
    Unit(
      id: 'eif_u2',
      name: 'Infrastructure development and projects unit',
      directorateId: 'electricity_infrastructure_facilities',
    ),
    Unit(
      id: 'eif_u3',
      name: 'Facility maintenance and utilities unit',
      directorateId: 'electricity_infrastructure_facilities',
    ),
    Unit(
      id: 'eif_u4',
      name: 'Assets and equipment maintenance unit',
      directorateId: 'electricity_infrastructure_facilities',
    ),
  ],
  'education_schools': const [],
  'child_evangelism_training': const [
    Unit(
      id: 'cet_u1',
      name: 'Child evangelism and gospel outreach unit',
      directorateId: 'child_evangelism_training',
    ),
    Unit(
      id: 'cet_u2',
      name: 'Biblical instructions and curriculum unit',
      directorateId: 'child_evangelism_training',
    ),
    Unit(
      id: 'cet_u3',
      name: 'Character formation and life skill unit',
      directorateId: 'child_evangelism_training',
    ),
    Unit(
      id: 'cet_u4',
      name: 'Child safety, welfare and care unit',
      directorateId: 'child_evangelism_training',
    ),
  ],
};

/// Units for a directorate. Returns an empty list when none are defined.
List<Unit> unitsForDirectorate(String directorateId) {
  final list = kSeedUnitsByDirectorate[directorateId];
  if (list != null) return list;
  return const [];
}
