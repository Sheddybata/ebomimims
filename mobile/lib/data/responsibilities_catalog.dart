import '../models/directorate_responsibilities.dart';
import 'responsibilities/resp_batch1.dart';
import 'responsibilities/resp_batch2.dart';
import 'responsibilities/resp_batch3.dart';
import 'responsibilities/resp_batch4.dart';

/// Full charter text + Bible verses per directorate (IDs match `directorates.dart`).
final Map<String, DirectorateResponsibilities> kResponsibilitiesCatalog = {
  'missions_evangelism': kMissionsEvangelism,
  'intercession_prayer': kIntercessionPrayer,
  'programs_publicity': kProgramsPublicity,
  'administration_national_intl': kAdministration,
  'finance_treasury_supply': kFinanceTreasury,
  'discipleship_mentorship': kDiscipleshipMentorship,
  'ministerial_education_training': kMinisterialEducation,
  'music_governance_strategy': kMusicGovernance,
  'research_monitoring_eval': kResearchMonitoring,
  'audit_influence': kAuditInfluence,
  'politics_governance': kPoliticsGovernance,
  'inter_ministerial_services': kInterMinisterial,
  'intl_affairs_partnership': kIntlAffairsPartnership,
  'women_affairs': kWomenAffairs,
  'youth_affairs_social': kYouthAffairs,
  'child_evangelism_training': kChildEvangelism,
  'hospitality_welfare_humanitarian': kHospitalityWelfare,
  'health_services_infra': kHealthServices,
  'communication_transport_logistics': kCommunicationTransport,
  'security_defense': kSecurityDefense,
  'electricity_infrastructure_facilities': kElectricityInfrastructure,
  'education_schools': kEducationSchools,
};
