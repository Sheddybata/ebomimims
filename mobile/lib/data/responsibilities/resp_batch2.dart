import '../../models/directorate_responsibilities.dart';

const DirectorateResponsibilities kAdministration = DirectorateResponsibilities(
  spiritualFoundation: [
    'Exodus 18:21: "Moreover thou shalt provide out of all the people able men, such as fear God, men of truth, hating covetousness..."',
    'Colossians 3:23: "And whatsoever ye do, do it heartily, as to the Lord, and not unto men."',
  ],
  director: [
    'Administrative Authority (National Director): Chief enforcer of all EBOMIM corporate policies and operational standards.',
    'Gatekeeping: Acts as the primary filter for all correspondence and access to the Senior Leadership.',
    'Compliance Oversight: Audits the administrative health of all other 23 Directorates.',
  ],
  manager: [
    'Office Management: Oversees the day-to-day running of the National Secretariat.',
    'Staff Discipline: Monitors attendance, punctuality, and the professional conduct of all employees.',
    'Resource Allocation: Manages the distribution of office supplies and administrative assets.',
  ],
  unitHeadByUnitId: {
    'ad_u3': [
      'Recruitment: Facilitate the hiring process for staff and volunteers.',
      'Appraisals: Coordinate annual performance reviews for all directorate personnel.',
    ],
    'ad_u4': [
      'Archiving: Maintain a secure and organized institutional memory (minutes, policies, legal docs).',
      'Standardization: Ensure all directorates use the approved reporting templates.',
    ],
    'ad_u1': [
      'Communication: Manage incoming and outgoing official letters, emails, and memos.',
      'Protocol: Direct visitors to the appropriate offices or directorates.',
    ],
    'ad_u2': [
      'International correspondence: Support cross-border administrative coordination and documentation.',
      'Liaison: Facilitate communication between international offices and the national secretariat.',
    ],
  },
);

const DirectorateResponsibilities kFinanceTreasury = DirectorateResponsibilities(
  spiritualFoundation: [
    'Luke 16:11: "If therefore ye have not been faithful in the unrighteous mammon, who will commit to your trust the true riches?"',
    'Proverbs 27:23: "Be thou diligent to know the state of thy flocks, and look well to thy herds."',
  ],
  director: [
    'Financial Stewardship: Safeguard the ministry\'s capital and ensure zero-tolerance for waste.',
    'Policy Enforcement: Approve financial controls and procurement limits.',
    'Strategic Budgeting: Oversee the preparation of the National Budget.',
  ],
  manager: [
    'Transaction Monitoring: Verify daily financial entries and ensure they match physical records.',
    'Cash Flow Management: Monitor the liquidity of the ministry for immediate operational needs.',
    'Audit Readiness: Ensure all books are ready for internal and external audit at all times.',
  ],
  unitHeadByUnitId: {
    'fts_u1': [
      'Bookkeeping: Maintain accurate ledgers for all income and expenditures.',
      'Reporting: Generate monthly financial statements for the Director.',
    ],
    'fts_u2': [
      'Security: Manage bank relationships and the physical security of tithes, offerings, and seeds.',
      'Disbursement: Process approved payments to vendors and staff.',
    ],
    'fts_u3': [
      'Vendor Selection: Source and vet suppliers for price, quality, and reliability.',
      'Negotiation: Ensure the ministry gets the best value for every naira spent.',
    ],
    'fts_u4': [
      'Asset Tracking: Maintain a register of all physical assets and office consumables.',
      'Issuance: Control the release of supplies to units based on approved requests.',
    ],
  },
);

const DirectorateResponsibilities kDiscipleshipMentorship = DirectorateResponsibilities(
  spiritualFoundation: [
    'Matthew 28:20: "Teaching them to observe all things whatsoever I have commanded you..."',
    '2 Timothy 2:2: "And the things that thou hast heard of me among many witnesses, the same commit thou to faithful men, who shall be able to teach others also."',
  ],
  director: [
    'Curriculum Vision: Define the spiritual growth path and mentorship modules for all members of EBOMIM.',
    'Standardization: Ensure uniform discipleship practices across all national and international branches.',
    'Maturity Oversight: Monitor the "spiritual health index" of the ministry and approve advanced mentorship programs.',
  ],
  manager: [
    'Training Coordination: Oversee the scheduling of weekly discipleship classes and mentorship retreats.',
    'Resource Management: Ensure all discipleship manuals and digital study materials are available and distributed.',
    'Personnel Supervision: Manage the deployment of discipleship teachers and mentors across units.',
  ],
  unitHeadByUnitId: {
    'dm_u1': [
      'Foundational Training: Manage the "Believers\' Class" for those transitioning from the Missions Directorate.',
      'Baptism Coordination: Organize and document water baptism candidates.',
    ],
    'dm_u2': [
      'Leadership Development: Coordinate specialized mentoring circles for emerging leaders.',
      'Accountability Groups: Set up and monitor peer-to-peer accountability systems.',
    ],
    'dm_u3': [
      'Tracking: Maintain a database of member progress through the various stages of discipleship.',
      'Evaluation: Conduct periodic spiritual surveys to assess the impact of mentorship programs.',
    ],
    'dm_u4': [
      'Cell groups: Foster spiritual communities and small-group discipleship across branches.',
      'Integration: Align cell ministry with national discipleship standards.',
    ],
  },
);

const DirectorateResponsibilities kMinisterialEducation = DirectorateResponsibilities(
  spiritualFoundation: [
    'Ezra 7:10: "For Ezra had prepared his heart to seek the law of the Lord, and to do it, and to teach in Israel statutes and judgments."',
    'Proverbs 9:9: "Give instruction to a wise man, and he will be yet wiser: teach a just man, and he will increase in learning."',
  ],
  director: [
    'Academic Excellence: Set the academic and spiritual standards for the School of Ministry (SOM).',
    'Accreditation: Oversee the certification processes for graduating ministers.',
    'Faculty Oversight: Approve the appointment of lecturers and training facilitators.',
  ],
  manager: [
    'Registrarial Oversight: Manage admissions, examinations, and the student information system.',
    'Budgetary Implementation: Execute the training budget as approved by the Director and NDA.',
    'Environment Management: Ensure classrooms and training facilities are conducive for learning.',
  ],
  unitHeadByUnitId: {
    'met_provost': [
      'Provost: Provide spiritual and academic leadership for EBOMIM School of Ministry under the Director.',
      'Standards: Uphold accreditation, faculty conduct, and student welfare aligned with national policy.',
    ],
    'met_u1': [
      'Manual Production: Draft and update textbooks, lecture notes, and training guides.',
      'Theological Review: Ensure all content is biblically sound and aligns with the ministry\'s vision.',
    ],
    'met_u2': [
      'Internship Management: Coordinate "Post-Training" field assignments for students.',
      'Supervision: Monitor students\' practical performance in evangelism, prayer, and administration.',
    ],
    'met_u3': [
      'Refresher Courses: Organize mandatory periodic training for existing senior ministers.',
      'Skill Acquisition: Provide training in contemporary ministry tools (tech, communication, etc.).',
    ],
    'met_u4': [
      'Leadership & ethics: Deliver modules on character, ethics, and leadership formation for ministers-in-training.',
      'Assessment: Evaluate practical outcomes tied to leadership and pastoral integrity.',
    ],
  },
);

const DirectorateResponsibilities kMusicGovernance = DirectorateResponsibilities(
  spiritualFoundation: [
    'Psalm 33:3: "Sing unto him a new song; play skilfully with a loud noise."',
    '2 Chronicles 20:21: "And when he had consulted with the people, he appointed singers unto the Lord..."',
  ],
  director: [
    'Sound Governance: Shape the musical "identity" and sound of the ministry to reflect the EBOMIM mandate.',
    'Strategic Worship: Design the flow of worship for national programs to align with prophetic themes.',
    'Technical Integrity: Ensure the highest standard of musical excellence and spiritual purity among musicians.',
  ],
  manager: [
    'Rehearsal Coordination: Manage the weekly schedules for choirs and instrumentalists.',
    'Equipment Oversight: Supervise the purchase and maintenance of musical instruments and sound gear.',
    'Welfare Management: Monitor the spiritual and physical well-being of the music personnel.',
  ],
  unitHeadByUnitId: {
    'mgs_u1': [
      'Worship & praise: Lead corporate worship sets aligned with prophetic themes.',
      'Excellence: Maintain vocal and spiritual readiness for national services.',
    ],
    'mgs_u2': [
      'Training: Oversee vocal drills and parts (soprano, alto, tenor) for all choristers.',
      'Uniformity: Manage choir robes, dress codes, and stage appearance protocols.',
    ],
    'mgs_u3': [
      'Performance: Provide skilled musical accompaniment for all services.',
      'Audio Quality: Manage sound mixing and live recording quality.',
    ],
    'mgs_u4': [
      'Composition: Encourage the writing and recording of original ministry songs.',
      'Curation: Select and vet songs for corporate worship to ensure doctrinal accuracy.',
    ],
  },
);

const DirectorateResponsibilities kResearchMonitoring = DirectorateResponsibilities(
  spiritualFoundation: [
    'Numbers 13:17-20: "And see the land, what it is; and the people that dwelleth therein, whether they be strong or weak, few or many..."',
    'Luke 14:28: "For which of you, intending to build a tower, sitteth not down first, and counteth the cost..."',
  ],
  director: [
    'Data Sovereignty: Ensure that every decision made at the national level is supported by verified data.',
    'Strategic Research: Identify emerging trends in global ministry and social impact to inform EBOMIM\'s plans.',
    'Impact Assessment: Approve the "Key Performance Indicators" (KPIs) for all other 23 directorates.',
  ],
  manager: [
    'Information Gathering: Coordinate field researchers to gather data on church growth and community needs.',
    'Database Integrity: Manage the ministry’s central data warehouse.',
    'Reporting: Translate raw data into visual dashboards for the Senior Resident Pastor (SRP) and NDA.',
  ],
  unitHeadByUnitId: {
    'rme_u1': [
      'Surveys: Conduct periodic member feedback surveys and community need assessments.',
      'Benchmarking: Compare EBOMIM\'s operational efficiency against set annual targets.',
    ],
    'rme_u2': [
      'Audit: Visit branches and directorates to verify physical progress on projects.',
      'Verification: Ensure that "numbers" reported in meetings match the reality on the ground.',
    ],
    'rme_u3': [
      'Mass Action: Coordinate the mobilization of members for national rallies or special interventions.',
      'Outreach Data: Track the success rate of various mobilization strategies.',
    ],
    'rme_u4': [
      'Evaluation cycles: Support cross-directorate performance reviews and reporting quality.',
      'Insights: Package findings for leadership decision-making.',
    ],
  },
);
