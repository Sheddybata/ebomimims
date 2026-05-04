import '../../models/directorate_responsibilities.dart';

/// Missions & Evangelism — full charter + verses.
const DirectorateResponsibilities kMissionsEvangelism = DirectorateResponsibilities(
  spiritualFoundation: [
    'Matthew 28:19-20: "Go ye therefore, and teach all nations, baptizing them in the name of the Father, and of the Son, and of the Holy Ghost: Teaching them to observe all things whatsoever I have commanded you..."',
    'Mark 16:15: "And he said unto them, Go ye into all the world, and preach the gospel to every creature."',
  ],
  director: [
    'Visionary Translation: Translate the General Overseer\'s mandates and the National Master Plan into actionable evangelistic strategies.',
    'Strategic Leadership: Provide the overarching roadmap, annual goals, and thematic direction for all missionary activities in Nigeria.',
    'Doctrinal Oversight: Ensure every crusade and outreach aligns strictly with EBOMIM\'s spiritual doctrines.',
    'Final Approval: Review and grant final approval for all mission concepts, budgets, and project timelines.',
    'High-Level Representation: Represent the directorate in National Council meetings.',
    'Accountability: Accountable to the G.O. (through the A.G.O.) for the growth and spiritual health of missions.',
  ],
  manager: [
    'Operational Implementation: Convert the Director\'s strategies into weekly and monthly work plans.',
    'Logistics Coordination: Oversee mobilization of resources, personnel, and equipment for field missions.',
    'Supervisory Oversight: Monitor the performance of Unit Heads, ensuring deadlines and quality standards.',
    'Reporting: Collate data from units to produce comprehensive reports for the Director and the NDA.',
    'Conflict Resolution: Resolve internal operational hitches and personnel disputes within the directorate.',
  ],
  unitHeadByUnitId: {
    'me_u1': [
      'Execution: Organize weekly local evangelism and "Go-Ye" sessions within communities.',
      'Data Collection: Maintain records of persons reached and initial contact details.',
      'Mobilization: Supervise the deployment of foot soldiers for door-to-door outreach.',
    ],
    'me_u2': [
      'Field Operations: Coordinate work in underserved or unreached rural areas.',
      'Support: Provide logistical support for resident missionaries in the field.',
      'Assessment: Report on the physical and spiritual needs of rural mission stations.',
    ],
    'me_u3': [
      'Event Planning: Handle the technical and logistical setup for large-scale national and regional crusades.',
      'Coordination: Manage stage, sound, and crowd control protocols during mass gatherings.',
    ],
    'me_u4': [
      'Follow-up: Ensure every convert is documented and contacted within 24–48 hours.',
      'Transition: Hand over converts to the Directorate of Discipleship and Mentorship for formal integration.',
    ],
  },
);

const DirectorateResponsibilities kIntercessionPrayer = DirectorateResponsibilities(
  spiritualFoundation: [
    '1 Thessalonians 5:17: "Pray without ceasing."',
    'Luke 18:1: "And he spake a parable unto them to this end, that men ought always to pray, and not to faint."',
  ],
  director: [
    'Prophetic Alignment: Develop the national prayer direction and themes for the ministry.',
    'Spiritual Gatekeeping: Provide spiritual covering and "intelligence" for all national programs.',
    'Strategy: Design the structure of national prayer chains and vigils.',
  ],
  manager: [
    'Schedule Management: Implement and monitor the 24/7 prayer roster.',
    'Participation Tracking: Ensure all assigned intercessors are active and present during their shifts.',
    'Resource Provision: Ensure prayer venues and communication tools for remote intercessors are functional.',
  ],
  unitHeadByUnitId: {
    'ip_u1': [
      'Daily Maintenance: Manage the daily scheduled prayer life at the national headquarters and branches.',
      'Urgent Intercession: Mobilize "Emergency Prayer Squads" for immediate ministry needs.',
    ],
    'ip_u2': [
      'Database Management: Maintain the national directory of verified intercessors across all branches.',
      'Communication: Disseminate prayer points and bulletins to the network.',
    ],
    'ip_u3': [
      'Recording: Document visions, revelations, and prophetic words received during intercession.',
      'Reporting: Submit summarized spiritual reports to the Director for review.',
    ],
    'ip_u4': [
      'Coordination: Oversee the logistics and guidelines for corporate fasting seasons.',
      'Exhortation: Provide daily scriptural encouragement for those on fasts.',
    ],
  },
);

/// National Programs & Publicity + International digital focus (merged).
const DirectorateResponsibilities kProgramsPublicity = DirectorateResponsibilities(
  spiritualFoundation: [
    'Habakkuk 2:2: "Write the vision, and make it plain upon tables, that he may run that readeth it."',
    '1 Corinthians 14:40: "Let all things be done decently and in order."',
    'Mark 16:15: "Go ye into all the world, and preach the gospel to every creature."',
    'Psalm 68:11: "The Lord gave the word: great was the company of those that published it."',
  ],
  director: [
    '[National] Brand Custodianship: Protect the public image and branding of EBOMIM Master National.',
    '[National] Strategic Planning: Translate the G.O.\'s annual calendar into structured, high-impact programs.',
    '[National] Policy Control: Approve all publicity materials (flyers, jingles, social media) before release.',
    '[International] Global Branding: Ensure the EBOMIM brand is consistently represented across international digital platforms.',
    '[International] Content Strategy: Approve the "global broadcast" standards for all international streaming services.',
    '[International] Media Policy: Set guidelines for press releases and international media interviews.',
  ],
  manager: [
    '[National] Milestone Tracking: Monitor the "count-down" to major events, ensuring all units are on schedule.',
    '[National] Venue Coordination: Oversee the physical or digital space requirements for programs.',
    '[National] Feedback Loops: Collate attendance data and program reviews for post-event analysis.',
    '[International] Production Management: Oversee the technical crew for live streams and international broadcasts.',
    '[International] Promotion Coordination: Manage the "International Program Calendar" to ensure time-zone synchronized publicity.',
    '[International] Vendor Management: Supervise external media consultants and PR agencies.',
  ],
  unitHeadByUnitId: {
    'pp_u1': [
      '[National] Scripting: Develop program session flows, themes, and "Order of Service."',
      '[National] Speaker Liaison: Coordinate with guest ministers and speakers regarding schedules.',
    ],
    'pp_u2': [
      '[National] Conflict Resolution: Maintain the national master calendar to prevent clashing dates between directorates.',
      '[National] Updates: Communicate calendar changes immediately to all stakeholders.',
    ],
    'pp_u3': [
      '[National] Dissemination: Manage the distribution of announcements via radio, TV, and social media.',
      '[National] Content Creation: Supervise the production of flyers, banners, and promotional videos.',
      '[International] Presence: Manage all official international social media handles (Facebook, YouTube, X, Instagram).',
      '[International] Engagement: Monitor comments and inquiries from the global audience, providing timely responses.',
    ],
    'pp_u4': [
      '[National] Data Analytics: Measure the effectiveness of programs (reach, conversion, attendance).',
      '[National] Documentation: Produce "Lesson Learned" reports for future improvements.',
      '[International] Streaming: Ensure high-quality audio and video transmission for all major programs.',
      '[International] Archiving: Maintain a digital library of all international sermons and events.',
      '[International] Aesthetics: Produce all digital flyers, motion graphics, and program trailers; ensure branding follows approved palette and logo usage.',
    ],
  },
);
