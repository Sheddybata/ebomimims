# Supabase Backend/API Sync Plan

This plan turns the IMS from local demo data into one shared source of truth for Flutter mobile and the web admin portal.

## Goal

- Mobile users submit reports, metrics, files, revisions, and inbox actions to Supabase.
- Web executives review the same reports from Supabase.
- NDA, AGO, GO, and Super Admin only see the records their role allows.
- Every workflow action is stored in a permanent timeline.
- Approved and returned reports create inbox notices for Unit Heads, Managers, and Directors.
- Firebase Cloud Messaging remains for push notifications only.

## Recommended Stack

- Supabase Auth: login and user identity.
- Supabase PostgreSQL: reports, metrics, workflow stages, timelines, inbox notices, roles, directorates, units.
- Supabase Row Level Security: strict access control at database level.
- Supabase Storage: report attachments.
- Next.js service layer: web admin reads/actions.
- Flutter Supabase client: mobile submit, review, inbox, resubmit.
- Firebase Cloud Messaging: mobile push notifications triggered after important workflow events.

## Roles

Use these canonical role ids everywhere:

- `unit_head`
- `manager`
- `director`
- `nda`
- `ago`
- `general_overseer`
- `super_admin`

NDA display name:

- `NDA (National Director of Administration)`

## Report Stages

Use one stage field for the full report journey:

- `draft`
- `awaiting_manager`
- `awaiting_director`
- `revision_requested`
- `awaiting_administration`
- `awaiting_ago`
- `awaiting_general_overseer`
- `returned_for_revision`
- `approved`
- `archived`

The normal path:

`unit_head -> manager -> director -> nda -> ago -> general_overseer -> approved`

Return paths:

- Manager returns to Unit Head: `revision_requested`
- Director returns to Manager or Unit Head: `revision_requested`
- NDA, AGO, or GO returns to author chain: `returned_for_revision`

## Core Tables

### `profiles`

One row per authenticated user.

Important fields:

- `id uuid primary key references auth.users(id)`
- `full_name text not null`
- `role text not null`
- `directorate_id uuid null`
- `unit_id uuid null`
- `manager_id uuid null`
- `director_id uuid null`
- `is_active boolean default true`
- `created_at timestamptz default now()`
- `updated_at timestamptz default now()`

Purpose:

- Stores app role and reporting line.
- Lets RLS decide who can see or act on a report.

### `directorates`

Important fields:

- `id uuid primary key`
- `code text unique not null`
- `name text not null`
- `description text null`
- `is_active boolean default true`

### `units`

Important fields:

- `id uuid primary key`
- `directorate_id uuid references directorates(id)`
- `code text unique not null`
- `name text not null`
- `is_active boolean default true`

### `reports`

This replaces local web pipeline reports and mobile in-memory reports.

Important fields:

- `id uuid primary key`
- `title text not null`
- `body text not null`
- `report_type text not null`
- `stage text not null`
- `directorate_id uuid references directorates(id)`
- `unit_id uuid null references units(id)`
- `author_id uuid references profiles(id)`
- `author_role text not null`
- `current_reviewer_role text null`
- `returned_note text null`
- `returned_by uuid null references profiles(id)`
- `returned_at timestamptz null`
- `submitted_at timestamptz default now()`
- `created_at timestamptz default now()`
- `updated_at timestamptz default now()`

Recommended indexes:

- `reports(stage)`
- `reports(author_id)`
- `reports(directorate_id)`
- `reports(unit_id)`
- `reports(current_reviewer_role)`
- `reports(created_at)`

### `report_metrics`

Stores structured metrics from mobile smart forms.

Important fields:

- `id uuid primary key`
- `report_id uuid references reports(id) on delete cascade`
- `metric_key text not null`
- `metric_label text not null`
- `metric_value text not null`
- `value_type text default 'text'`
- `sort_order int default 0`

Unique rule:

- Unique on `report_id, metric_key`

### `report_timeline`

Permanent audit history.

Important fields:

- `id uuid primary key`
- `report_id uuid references reports(id) on delete cascade`
- `action text not null`
- `label text not null`
- `actor_id uuid null references profiles(id)`
- `actor_role text not null`
- `actor_name text not null`
- `note text null`
- `created_at timestamptz default now()`

Actions:

- `submitted`
- `forwarded_to_manager`
- `forwarded_to_director`
- `submitted_to_nda`
- `forwarded_to_ago`
- `forwarded_to_go`
- `approved_by_go`
- `returned_for_revision`
- `resubmitted`

### `report_inbox_notices`

Inbox notifications for approved and returned reports.

Important fields:

- `id uuid primary key`
- `report_id uuid references reports(id) on delete cascade`
- `recipient_id uuid references profiles(id)`
- `recipient_role text not null`
- `status text not null`
- `title text not null`
- `message text not null`
- `actor_id uuid null references profiles(id)`
- `actor_role text not null`
- `note text null`
- `read_at timestamptz null`
- `created_at timestamptz default now()`

Statuses:

- `approved`
- `returned_for_revision`
- `needs_action`

### `report_attachments`

Important fields:

- `id uuid primary key`
- `report_id uuid references reports(id) on delete cascade`
- `uploaded_by uuid references profiles(id)`
- `file_name text not null`
- `storage_path text not null`
- `mime_type text null`
- `file_size_bytes bigint null`
- `created_at timestamptz default now()`

## Workflow Functions

Use database functions or API service functions for workflow actions. Do not let clients freely update `stage`.

Required actions:

- `submit_report(report_input, metrics, attachments)`
- `manager_forward_to_director(report_id)`
- `manager_return_for_revision(report_id, note)`
- `director_submit_to_nda(report_id)`
- `director_return_for_revision(report_id, note)`
- `nda_forward_to_ago(report_id)`
- `ago_forward_to_go(report_id)`
- `go_approve_report(report_id)`
- `executive_return_for_revision(report_id, note)`
- `resubmit_report(report_id, updated_body, updated_metrics)`
- `mark_inbox_notice_read(notice_id)`

Each action must:

- Validate the current stage.
- Validate the current user role.
- Update the report stage.
- Insert one `report_timeline` row.
- Create inbox notices where needed.
- Trigger push notification where needed.

## Row Level Security Rules

High-level access rules:

- Super Admin can read all reports, metrics, timelines, and notices, but should not approve executive reports.
- Unit Head can read and edit their own reports while draft or revision requested.
- Manager can read reports from assigned Unit Heads awaiting manager review.
- Director can read reports in their directorate awaiting director review.
- NDA can read reports where `stage = 'awaiting_administration'`.
- AGO can read reports where `stage = 'awaiting_ago'`.
- GO can read reports where `stage = 'awaiting_general_overseer'`.
- Approved reports can be read by Super Admin and the relevant author chain.
- Inbox notices can only be read by their recipient and Super Admin.

Important:

- RLS protects read access.
- Workflow functions protect write/action access.
- The web UI should still hide unavailable actions, but the database must enforce the real rule.

## Web Migration Steps

### Phase 1: Add Supabase Client

- Install `@supabase/supabase-js`.
- Add `.env.local` values:
  - `NEXT_PUBLIC_SUPABASE_URL`
  - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- Create `lib/supabase/client.ts`.
- Keep current local demo stores until the first Supabase screen is working.

### Phase 2: Replace Executive Pipeline Store

Replace:

- `lib/ims-reports/pipelineStore.ts`
- `lib/ims-reports/executiveInboxStore.ts`

With Supabase-backed services:

- `getExecutiveReportsForRole(role)`
- `forwardReport(reportId, action)`
- `returnReportForRevision(reportId, note)`
- `approveReport(reportId)`
- `getOutcomeInboxNotices()`

### Phase 3: Replace Super Admin Overview

Update:

- `/admin/dashboard`
- `/admin/ims-pipeline`
- `/admin/compliance-dashboard`

To read real counts from Supabase.

### Phase 4: Remove Demo Reset Controls

After Supabase is active:

- Remove local reset buttons.
- Keep seed scripts in SQL or a private dev-only setup script.

## Flutter Migration Steps

### Phase 1: Add Supabase Client

- Add `supabase_flutter`.
- Initialize Supabase at app startup.
- Move login/session to Supabase Auth.

### Phase 2: Submit Reports

Replace local/in-memory submit with:

- Insert into `reports`.
- Insert into `report_metrics`.
- Upload attachments to Supabase Storage.
- Insert first timeline event.

### Phase 3: Review and Inbox

Mobile screens should read:

- Assigned reports by stage.
- Returned reports.
- Inbox notices.
- Full timeline.
- Metrics.

### Phase 4: Offline Support

Keep current offline queue idea, but point it to Supabase:

- Queue failed submissions locally.
- Retry when connection returns.
- Mark each queued item with `sync_status`.

## Notification Plan

Use Firebase Cloud Messaging for push only.

Trigger notifications when:

- A manager receives a new report.
- A director receives a new report.
- NDA receives a new report.
- AGO receives a new report.
- GO receives a new report.
- A report is returned for revision.
- A report is approved.

Store device tokens in:

- `profile_device_tokens`

Suggested fields:

- `id uuid primary key`
- `profile_id uuid references profiles(id)`
- `platform text not null`
- `token text not null`
- `created_at timestamptz default now()`
- `last_seen_at timestamptz default now()`

## Implementation Order

Recommended build order:

1. Create Supabase project.
2. Create database tables and enums.
3. Add RLS policies.
4. Add seed data for roles, directorates, units, and sample users.
5. Connect web login to Supabase Auth.
6. Connect web executive pipeline to Supabase.
7. Connect web Super Admin dashboard to Supabase.
8. Connect Flutter login to Supabase Auth.
9. Connect Flutter submit/inbox/revision screens to Supabase.
10. Add FCM push notification triggers.
11. Remove old localStorage/in-memory demo paths.

## First Technical Task

Create the Supabase schema migration with:

- Role/stage enums or check constraints.
- `profiles`
- `directorates`
- `units`
- `reports`
- `report_metrics`
- `report_timeline`
- `report_inbox_notices`
- `report_attachments`
- `profile_device_tokens`
- Starter RLS policies

After that, connect only one vertical slice first:

`Director approves report -> NDA sees it on web from Supabase`

Once that works, connect:

`NDA -> AGO -> GO -> Approved -> Inbox notices`
