# Information Management System Leadership Submission Report

**Prepared for:** Executive Leadership, National Administration, and Ministry Governance Review  
**Subject:** Progress report on the IMS mobile reporting, state coordination, and executive approval platform  
**Purpose:** To document what has been achieved so far, explain the value to leadership, and recommend the next phase of adoption.

## Executive Summary

The Information Management System (IMS) has been developed as a unified ministry reporting and executive review platform. Its purpose is to move the organisation away from scattered manual reports, isolated local records, and unclear approval paths into one accountable system where information is submitted, reviewed, tracked, and preserved with integrity.

The current phase has delivered a working foundation across the mobile application, web administration portal, and secure backend. Field officers and ministry leaders can submit structured reports from the mobile app, while leadership can review and act on those reports through a governed web workflow. The system now supports directorate reporting and a national State Coordinator model covering the 36 states of Nigeria and the Federal Capital Territory.

Most importantly, IMS is no longer just a form collection tool. It has become a governance platform for ministry administration. It helps leadership know what is happening, where it is happening, who reported it, when it was reviewed, and what decision was taken.

This report should be read together with the IMS Mobile App Brochure Copy, which presents the mobile app experience in a simpler format for awareness, training, and adoption.

## The Challenge Before IMS

Before this phase, reporting was at risk of becoming fragmented. Different units and coordinator functions could submit information through disconnected channels, and some legacy web modules depended on local browser storage instead of a secure central database. This created practical risks:

- Important reports could exist in different places instead of one trusted record.
- Leadership visibility depended on manual follow-up and individual communication.
- Review history could be difficult to confirm.
- State-level ministry activity did not have a proper national reporting channel.
- Approval responsibility across administration and executive leadership needed clearer structure.

IMS addresses these problems by creating one reporting pipeline, one data source, and one leadership review chain.

## What Has Been Built So Far

### 1. Unified Supabase Backend

The system now uses Supabase as the central backend for authentication, database storage, and controlled access. Key records such as user profiles, reports, metrics, inbox notices, and review timelines are kept in one structured database.

This gives the organisation a dependable system of record. Reports are no longer treated as isolated submissions; they become trackable organisational records with authorship, status, timestamps, and review history.

### 2. Mobile Application for Report Authors

The mobile app has been shaped around the people who actually submit reports. Users sign in with email and password, then access a role-aware dashboard. Depending on their role, they can submit reports, receive inbox notices, review feedback, resubmit revisions, and view submission history.

The mobile experience currently supports:

- Login and account creation.
- Role-aware home dashboard.
- Structured report submission.
- Inbox for approvals, rejection notices, and revision requests.
- Report review and resubmission flows.
- Report history.
- Profile view showing role, directorate/unit, or state assignment.

### 3. Web Administration and Executive Review

The web portal supports leadership review and oversight. The review chain has been aligned around national administration and executive authority:

- National Director of Administration (NDA)
- Associate General Overseer (AGO)
- General Overseer (GO)

Reports move through defined stages, and executive users see queues and history relevant to their responsibility. This ensures that leadership does not depend on assumed or decorative data. The web interface reflects live report records from the unified backend.

### 4. Retirement of Legacy Coordinator Modules

The older web coordinator modules for separate local forms have been retired. This was a major architectural cleanup. Instead of maintaining multiple disconnected reporting systems, IMS now uses the same secure pipeline for all serious ministry reporting.

This simplifies training, reduces confusion, improves data integrity, and prepares the organisation for proper national reporting.

## Mobile Reporting and User Roles

The mobile app recognises four key reporting roles:

- **Unit Head:** submits operational or unit-level information.
- **Manager:** participates in managerial reporting and review flow.
- **Director:** handles directorate-level reporting and strategic oversight.
- **State Coordinator:** submits state ministry reports directly into the national administration pipeline.

Each user experience is adapted to the user's role. This means the system does not ask every person the same questions. Instead, it presents the correct responsibilities, report structure, and context for that person's place in the organisation.

For directorate-based users, the system links the user to the relevant directorate and unit. For State Coordinators, the system links the user to a state or the Federal Capital Territory.

## State Coordinator National Asset Model

One of the most important improvements in this phase is the transformation of the coordinator concept into a national asset model.

Rather than treating coordinators as separate legacy forms, the system now recognises State Coordinators as official reporting actors in the IMS structure. During account creation, a State Coordinator selects their state from a controlled list of 37 jurisdictions: the 36 Nigerian states plus the Federal Capital Territory.

The State Coordinator report framework currently supports core ministry indicators such as:

- Total attendance.
- Total offering.
- Testimonies and ministry updates.

This creates a national reporting channel for state activity. It allows administration to see the pulse of ministry work across states and creates a foundation for future state-by-state analytics.

## Executive Approval Workflow

IMS now supports a defined leadership review pattern. Reports are submitted into the system and then move through the appropriate review chain.

For the national executive pathway, the system supports:

1. Review by the National Director of Administration.
2. Forwarding to the Associate General Overseer.
3. Final review and decision by the General Overseer.

If a report requires correction, the system can request revision and return the matter to the author with an inbox notice. This gives the organisation a controlled feedback loop instead of informal correction outside the system.

State Coordinator reports are designed to go directly to the NDA for national administrative review. This avoids unnecessary intermediate layers and matches the leadership intent for state ministry reporting.

## Accountability, Audit Trail, and Data Integrity

IMS improves accountability in four practical ways:

### Authenticated Identity

Reports are attached to signed-in users. Leadership can know who submitted a report and which role or jurisdiction the person represents.

### Structured Metrics

Reports are not just free-text messages. The system captures defined metrics, allowing reports to be compared, reviewed, and eventually summarised across time.

### Timeline of Decisions

Review actions are preserved through status and timeline records. This makes it possible to understand how a report moved through the system.

### Inbox and History

Authors are not left guessing. They can see outcomes, revision requests, and previous submissions from within the mobile app.

Together, these features help IMS support discipline, transparency, and institutional memory.

## Administrative Benefits to Leadership

IMS gives leadership several immediate benefits:

- Faster visibility into ministry activity.
- Clearer accountability for report authors and reviewers.
- Reduced dependence on paper, spreadsheets, and scattered messages.
- Stronger national coordination across states.
- Better preparation for executive meetings and administrative review.
- A foundation for compliance dashboards and performance summaries.
- A repeatable reporting rhythm that can scale as the organisation grows.

The system also makes reporting easier to govern. Because submissions, review actions, and outcomes are recorded in one place, leadership can ask better questions and make decisions from a stronger evidence base.

## Current Technical Position

The current implementation is built on:

- **Flutter** for the mobile application.
- **Next.js** for the web administration portal.
- **Supabase** for authentication, database storage, row-level security, and review functions.

This stack gives the organisation a modern, maintainable foundation without unnecessary complexity. For non-technical leadership, the most important point is simple: the system is built to preserve one trusted record, enforce proper access, and support future growth without returning to scattered manual tools.

It also supports future expansion into dashboards, exports, attachments, push notifications, and deeper analytics.

## Recommended Next Phase

The next phase should focus on readiness, adoption, and leadership visibility.

### 1. End-to-End User Testing

Test the full flow for each role:

- Unit Head submission.
- Manager and Director review where applicable.
- State Coordinator submission.
- NDA review.
- AGO review.
- GO final approval.
- Revision request and author resubmission.

### 2. Leadership Dashboards

Build summary dashboards that answer leadership questions quickly:

- How many reports were submitted this week?
- Which directorates or states are active?
- Which reports are waiting for NDA, AGO, or GO?
- How long does each review stage take?
- How many reports were approved, rejected, or returned for revision?

### 3. Training and Adoption Materials

Prepare short guides for:

- Mobile app users.
- State Coordinators.
- NDA, AGO, and GO reviewers.
- System administrators.

### 4. Governance Rules

Define reporting frequency, required fields, escalation rules, and who is responsible for reviewing each class of report.

## Conclusion

The IMS project has reached a meaningful milestone. It now provides a single reporting pipeline from mobile submission to executive decision. It strengthens administration, supports national state coordination, and gives leadership a clearer view of ministry activity.

The work completed so far should be regarded as the foundation of a wider digital governance platform. With continued testing, training, and dashboard development, IMS can become the organisation's trusted command point for reporting, accountability, and informed leadership action.
