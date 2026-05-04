import '../models/directorate.dart';

/// Central catalogue — mirrors org structure (Firebase later).
const List<Directorate> kDirectorates = [
  Directorate(
    id: 'administration_national_intl',
    name: 'Directorate of Administration (National & International)',
    groupLabel: 'Central coordination',
    isAdministrationHub: true,
  ),
  Directorate(
    id: 'missions_evangelism',
    name: 'Directorate of Missions and Evangelism',
    groupLabel: 'Directorates',
  ),
  Directorate(
    id: 'intercession_prayer',
    name: 'Directorate of Intercession and Prayer (under National Coordinator)',
    groupLabel: 'Directorates',
  ),
  Directorate(
    id: 'discipleship_mentorship',
    name: 'Directorate of Discipleship and Mentorship',
    groupLabel: 'Directorates',
  ),
  Directorate(
    id: 'ministerial_education_training',
    name: 'Directorate of Ministerial Education and Training',
    groupLabel: 'Directorates',
  ),
  Directorate(
    id: 'music_governance_strategy',
    name: 'Directorate of Music, Governance, Strategy & Administration',
    groupLabel: 'Directorates',
  ),
  Directorate(
    id: 'politics_governance',
    name: 'Directorate of Politics and Governance',
    groupLabel: 'Directorates',
  ),
  Directorate(
    id: 'research_monitoring_eval',
    name:
        'Directorate of Research, Monitoring, Evaluation & Mobilization',
    groupLabel: 'Directorates',
  ),
  Directorate(
    id: 'finance_treasury_supply',
    name: 'Directorate of Finance, Treasury, Purchase & Supply',
    groupLabel: 'Directorates',
  ),
  Directorate(
    id: 'audit_influence',
    name:
        'Directorate Of Internal And External Audit Programs, Engagement & Influence',
    groupLabel: 'Directorates',
  ),
  Directorate(
    id: 'programs_publicity',
    name: 'Directorate of Programs and Publicity',
    groupLabel: 'Directorates',
  ),
  Directorate(
    id: 'inter_ministerial_services',
    name: 'Directorate of Inter-Ministerial Services',
    groupLabel: 'Directorates',
  ),
  Directorate(
    id: 'women_affairs',
    name: 'Directorate of Women Affairs',
    groupLabel: 'Directorates',
  ),
  Directorate(
    id: 'intl_affairs_partnership',
    name:
        'Directorate of International Affairs, Partnership & Mission, People, Care & Social Impact',
    groupLabel: 'Directorates',
  ),
  Directorate(
    id: 'youth_affairs_social',
    name: 'Directorate of Youth Affairs and Social Services',
    groupLabel: 'Directorates',
  ),
  Directorate(
    id: 'hospitality_welfare_humanitarian',
    name:
        'Directorate of Hospitality, Welfare & Humanitarian Affairs',
    groupLabel: 'Directorates',
  ),
  Directorate(
    id: 'security_defense',
    name: 'Directorate of Security and Defense',
    groupLabel: 'Directorates',
  ),
  Directorate(
    id: 'communication_transport_logistics',
    name: 'Directorate of Communication, Transport & Logistics',
    groupLabel: 'Directorates',
  ),
  Directorate(
    id: 'health_services_infra',
    name:
        'Directorate of Health Services Operations, Security & Infrastructure',
    groupLabel: 'Directorates',
  ),
  Directorate(
    id: 'electricity_infrastructure_facilities',
    name:
        'Directorate of Electricity, Infrastructure & Facility Maintenance',
    groupLabel: 'Future generation & education',
  ),
  Directorate(
    id: 'education_schools',
    name: 'Directorate of Education and Schools',
    groupLabel: 'Future generation & education',
  ),
  Directorate(
    id: 'child_evangelism_training',
    name: 'Directorate of Child Evangelism and Training',
    groupLabel: 'Future generation & education',
  ),
];

Directorate? directorateById(String id) {
  try {
    return kDirectorates.firstWhere((d) => d.id == id);
  } catch (_) {
    return null;
  }
}

String directorateName(String id) =>
    directorateById(id)?.name ?? 'Unknown directorate';
