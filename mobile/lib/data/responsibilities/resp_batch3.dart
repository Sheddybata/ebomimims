import '../../models/directorate_responsibilities.dart';

const DirectorateResponsibilities kAuditInfluence = DirectorateResponsibilities(
  spiritualFoundation: [
    '2 Corinthians 8:21: "Providing for honest things, not only in the sight of the Lord, but also in the sight of men."',
    'Daniel 6:4: "...but they could find none occasion nor fault; forasmuch as he was faithful..."',
  ],
  director: [
    'Independence: Maintain absolute objectivity and report directly to the G.O. and NDA.',
    'Risk Management: Identify financial and administrative "leakages" before they become crises.',
    'Audit Strategy: Approve the annual audit plan covering all subsidiaries and directorates.',
  ],
  manager: [
    'Field Audits: Lead surprise and scheduled audits of branch accounts and store inventories.',
    'Evidence Collection: Ensure all findings are backed by physical documents or digital logs.',
    'Corrective Tracking: Monitor whether directorates have implemented the changes recommended in previous audits.',
  ],
  unitHeadByUnitId: {
    'ai_u1': [
      'Verification: Inspect bank statements, tithing records, and petty cash vouchers.',
      'Forensics: Investigate any suspected financial misappropriation.',
    ],
    'ai_u2': [
      'Compliance: Ensure staff hiring and attendance records match the NDA\'s policies.',
      'Asset Verification: Physically count and verify the existence of all ministry assets (vehicles, electronics, land).',
    ],
    'ai_u3': [
      'Operational audit: Review administrative processes and internal controls across units.',
      'Reporting: Document findings and track remediation.',
    ],
    'ai_u4': [
      'Ethics & integrity: Investigate breaches of policy and recommend corrective action.',
      'Culture: Promote transparency and accountability.',
    ],
  },
);

const DirectorateResponsibilities kPoliticsGovernance = DirectorateResponsibilities(
  spiritualFoundation: [
    'Proverbs 29:2: "When the righteous are in authority, the people rejoice: but when the wicked beareth rule, the people mourn."',
    'Daniel 2:21: "And he changeth the times and the seasons: he removeth kings, and setteth up kings..."',
  ],
  director: [
    'Civic Vision: Shape the ministry\'s engagement with the political landscape to ensure Christian values influence governance.',
    'Diplomatic Oversight: Act as the primary liaison between the Senior Resident Pastor (SRP) and high-level government officials or traditional rulers.',
    'Policy Advocacy: Approve position papers and public statements regarding national legislation and social justice.',
  ],
  manager: [
    'Engagement Coordination: Manage the schedule for political sensitizations and "Voters\' Education" rallies.',
    'Networking: Build and maintain a database of believers in active politics and civil service.',
    'Mobilization Tracking: Monitor the progress of PVC (Permanent Voter Card) drives and civic registration within the ministry.',
  ],
  unitHeadByUnitId: {
    'pg_u1': [
      'Instruction: Organize seminars on the biblical basis for political participation.',
      'Awareness: Disseminate information on electoral processes and citizen rights.',
    ],
    'pg_u2': [
      'Representation: Attend official government functions as assigned by the Director.',
      'Intelligence: Monitor political trends and report potential impacts on religious freedom to the Directorate.',
    ],
    'pg_u3': [
      'Capacity Building: Organize "Leadership Schools" for Christians aspiring to public office.',
      'Ethics: Provide mentorship on maintaining integrity in secular governance.',
    ],
    'pg_u4': [
      'Advocacy coordination: Align grassroots advocacy with national policy priorities.',
      'Documentation: Maintain records of civic engagement outcomes.',
    ],
  },
);

const DirectorateResponsibilities kInterMinisterial = DirectorateResponsibilities(
  spiritualFoundation: [
    'Psalm 133:1: "Behold, how good and how pleasant it is for brethren to dwell together in unity!"',
    'John 17:21: "That they all may be one; as thou, Father, art in me, and I in thee..."',
  ],
  director: [
    'Strategic Alliance: Define the parameters for EBOMIM\'s collaboration with other Christian bodies (CAN, PFN, etc.).',
    'Unity Oversight: Ensure EBOMIM contributes effectively to the "Body of Christ" without compromising its core mandate.',
    'Conflict Resolution: Mediate in matters involving other ministries or external spiritual organizations.',
  ],
  manager: [
    'Meeting Coordination: Oversee the logistics for inter-denominational conferences and joint prayer sessions.',
    'Correspondence Management: Manage formal letters and invitations from other ministries.',
    'Database Maintenance: Keep an updated directory of partner ministries and their key leaders.',
  ],
  unitHeadByUnitId: {
    'ims_u1': [
      'Representation: Act as the operational link between EBOMIM and national religious councils.',
      'Compliance: Ensure EBOMIM’s activities align with the broader regulations of Christian associations.',
    ],
    'ims_u2': [
      'Joint Ventures: Coordinate shared mission projects or social interventions with partner churches.',
      'Resource Sharing: Manage the exchange of materials or personnel for collaborative kingdom work.',
    ],
    'ims_u3': [
      'Protocol & partnership execution: Coordinate official visits and joint programs.',
      'Documentation: Track agreements and outcomes.',
    ],
    'ims_u4': [
      'Liaison support: Support directorate-wide external relations and follow-up.',
      'Reporting: Summarize partnership health for leadership.',
    ],
  },
);

/// International Affairs + People, Care & Social Impact (merged per app directorate).
const DirectorateResponsibilities kIntlAffairsPartnership = DirectorateResponsibilities(
  spiritualFoundation: [
    'Genesis 12:3: "...and in thee shall all families of the earth be blessed."',
    'Isaiah 49:6: "...I will also give thee for a light to the Gentiles, that thou mayest be my salvation unto the end of the earth."',
    'Proverbs 11:25: "The liberal soul shall be made fat: and he that watereth shall be watered also himself."',
    'Acts 10:38: "...who went about doing good, and healing all that were oppressed of the devil; for God was with him."',
  ],
  director: [
    '[International] Global Expansion: Lead the strategic planting of EBOMIM branches in foreign nations.',
    '[International] Visa & Immigration Oversight: Approve all travel protocols for the Senior Resident Pastor and visiting international dignitaries.',
    '[International] Missionary Welfare: Ensure that international missionaries are adequately supported and secure.',
    '[People & Care] Human Capital Vision: Define the ministry\'s philosophy on staff welfare, growth, and "Kingdom Employment."',
    '[People & Care] Social Impact Strategy: Approve the metrics for measuring the ministry’s external impact on the community.',
    '[People & Care] Policy Design: Set the guidelines for staff leave, health insurance, and retirement benefits.',
  ],
  manager: [
    '[International] Logistics Coordination: Manage flight bookings, accommodation, and protocol for international travel.',
    '[International] Diplomatic Liaison: Coordinate with embassies and high commissions for official documentation.',
    '[International] Branch Monitoring: Collate reports from international missions for the SRP and NDA.',
    '[People & Care] Personnel Operations: Oversee the day-to-day HR functions (recruitment, onboarding, appraisals).',
    '[People & Care] Impact Reporting: Collate data from social projects to show the ministry’s footprint in society.',
    '[People & Care] Staff Welfare: Act as the primary advocate for employee well-being and grievance resolution.',
  ],
  unitHeadByUnitId: {
    'iap_u1': [
      '[International] Field Support: Provide administrative support to missionaries serving outside Nigeria.',
      '[International] Cross-Cultural Training: Prepare teams for the cultural nuances of their destination countries.',
      '[People & Care] CSR: Manage the ministry’s Corporate Social Responsibility projects.',
      '[People & Care] Relations: Maintain peaceful and productive relationships with host communities and local leaders.',
    ],
    'iap_u2': [
      '[International] Global partnership: Identify and manage relationships with international donors and partners.',
      '[International] Reporting: Prepare impact reports for global partners on shared projects.',
      '[People & Care] Talent Management & Recruitment: Source and vet candidates who align with EBOMIM values.',
      '[People & Care] Onboarding: Manage the orientation process for new staff across all 24 directorates.',
    ],
    'iap_u3': [
      '[International] Branches & diaspora: Coordinate international branches and diaspora engagement.',
      '[People & Care] Community impact: Track social outcomes tied to partnership projects.',
    ],
    'iap_u4': [
      '[International] Protocol & Immigration: Handle passport applications, visa processing, and airport protocols.',
      '[International] Hospitality: Ensure visiting international guests are received according to EBOMIM\'s high standards.',
      '[People & Care] Compliance: Align international operations with HR and welfare policy.',
    ],
  },
);

const DirectorateResponsibilities kWomenAffairs = DirectorateResponsibilities(
  spiritualFoundation: [
    'Proverbs 31:30: "Favour is deceitful, and beauty is vain: but a woman that feareth the Lord, she shall be praised."',
    'Titus 2:3-5: "The aged women likewise... that they may teach the young women..."',
  ],
  director: [
    'Holistic Growth: Define the spiritual, social, and economic development goals for all women in EBOMIM.',
    'Family Values Oversight: Ensure programs promote biblical marriage and godly parenting.',
    'Resource Approval: Approve budgets for women-specific conventions and empowerment schemes.',
  ],
  manager: [
    'Program Implementation: Oversee the execution of women\'s conferences, retreats, and "Home-Front" seminars.',
    'Membership Tracking: Manage the database of women\'s groups across various branches.',
    'Welfare Oversight: Coordinate support for widows, expectant mothers, and women in distress.',
  ],
  unitHeadByUnitId: {
    'wa_u1': [
      'Intercession: Lead the "Mothers\' Prayer" sessions for the ministry and the nation.',
      'Counseling: Provide biblically-based counseling for women and families.',
    ],
    'wa_u2': [
      'Training: Organize vocational skills workshops (tailoring, catering, entrepreneurship) for women.',
      'Micro-Credit Liaison: Coordinate access to small-scale financial support for women\'s businesses.',
    ],
    'wa_u3': [
      'Education: Organize seminars for wives and mothers on building godly homes.',
      'Mentorship: Facilitate "Older Women mentoring Younger Women" programs.',
    ],
    'wa_u4': [
      'Mobilization & outreach: Coordinate women-led evangelism and community initiatives.',
      'Reporting: Track participation and spiritual growth metrics.',
    ],
  },
);

const DirectorateResponsibilities kYouthAffairs = DirectorateResponsibilities(
  spiritualFoundation: [
    'Ecclesiastes 12:1: "Remember now thy Creator in the days of thy youth..."',
    '1 Timothy 4:12: "Let no man despise thy youth; but be thou an example of the believers..."',
  ],
  director: [
    'Generational Vision: Define the strategic path for the spiritual and professional empowerment of all EBOMIM youth.',
    'Resource Approval: Grant final approval for national youth conventions, summits, and skill acquisition funding.',
    'Moral Oversight: Ensure youth programs maintain high standards of biblical holiness while remaining contemporary and engaging.',
  ],
  manager: [
    'Project Execution: Oversee the logistics for youth rallies, career fairs, and social intervention projects.',
    'Mentorship Coordination: Manage the link between senior professionals in the church and the youth body.',
    'Data Management: Maintain a comprehensive database of youth demographics, including their academic and professional status.',
  ],
  unitHeadByUnitId: {
    'yas_u1': [
      'Guidance: Organize workshops on CV writing, interview skills, and professional certifications.',
      'Opportunity Linkage: Identify internship and job opportunities for qualified youth within the ministry\'s network.',
    ],
    'yas_u2': [
      'Activation: Identify and nurture talents in drama, spoken word, digital arts, and tech.',
      'Showcasing: Organize platforms for youth to use their creative gifts for kingdom advancement.',
    ],
    'yas_u3': [
      'Intervention: Coordinate youth-led community service projects (cleaning, visitations, social advocacy).',
      'Counseling: Provide specialized peer-to-peer counseling on drug abuse, mental health, and relationships.',
    ],
    'yas_u4': [
      'Mobilization: Support national youth drives and branch-level youth initiatives.',
      'Reporting: Track engagement and outcomes.',
    ],
  },
);
