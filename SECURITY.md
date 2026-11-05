# Security

Do not include credentials, private source or customer data in public issues.
For a security issue, use this repository's GitHub private vulnerability reporting
feature when enabled. If unavailable, open an issue asking for a private contact
without disclosing exploit details or sensitive data.

The installer runs with the caller's filesystem permissions. It reads bundled
instructions and writes project-local files; it does not execute workflow text,
call models, download scripts, start services or change global client settings.

Review dependency updates and generated diffs as code. Checksums detect drift;
they are not a signature or a guarantee against a malicious dependency. Use a
trusted, pinned release and keep the project in version control. Concurrent
writers and unexpected filesystem interruption are outside the installer's
transaction guarantees; see the architecture document for recovery.
