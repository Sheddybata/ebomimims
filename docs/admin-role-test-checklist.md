# Admin Role Test Checklist

Use this checklist after admin or executive workflow changes.

## Super Admin

- Log in with `admin`.
- Confirm the user lands on `/admin/dashboard`.
- Confirm the sidebar shows Command Center, Executive Pipeline, and Weekly Compliance only.
- Confirm `/admin/ims-pipeline` is read-only and shows full report body, metrics, report type, timeline, returned notes, approved archive, and outcome inbox notices.
- Confirm reset controls are hidden under Developer tools.

## NDA

- Log in with `nda`.
- Confirm the user only sees the NDA executive portal.
- Confirm only reports in `awaiting_administration` appear.
- Open a report and confirm the dialog shows decision summary, metrics, full report body, and report journey.
- Forward to AGO and confirm the report leaves the NDA queue.
- Return a report with a note under the minimum length and confirm the validation message appears.
- Return a report with a valid note and confirm it moves to returned for revision with the note saved.

## AGO

- Log in with `ago`.
- Confirm the user only sees the AGO executive portal.
- Confirm only reports in `awaiting_ago` appear.
- Open a report and confirm the dialog shows decision summary, metrics, full report body, and report journey.
- Send to GO and confirm the report leaves the AGO queue.
- Return a report with a valid note and confirm it moves to returned for revision with the note saved.

## GO

- Log in with `go`.
- Confirm the user only sees the GO executive portal.
- Confirm only reports in `awaiting_general_overseer` appear.
- Open a report and confirm the dialog shows decision summary, metrics, full report body, and report journey.
- Approve a report and confirm it moves to the approved archive.
- Confirm approval creates outcome inbox notices for the author chain.
- Return a report with a valid note and confirm it creates returned outcome notices.

## Access Guard

- While logged in as NDA, AGO, or GO, try opening the other executive URLs directly.
- Confirm each role is redirected away from pages it should not access.
- While logged in as Super Admin, try opening NDA, AGO, and GO URLs directly.
- Confirm Super Admin cannot act as an executive user.
