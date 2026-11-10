# Career Manager

A local-first macOS career dashboard for tracking opportunities and handing selected applications to Codex. Search uses Remotive's public remote-jobs feed; availability and location eligibility must be checked at the employer.

## Start

Requirements: macOS, Python 3, Swift command-line tools, and an installed and signed-in Codex CLI on PATH. Run `./script/build_and_run.sh` to build and open `dist/Career Manager.app`. Your private tracker and batch data live in `~/.career-manager`, not the repository.

Enter the absolute path to your résumé PDF and your portfolio URL in Career settings. Search, select listings, then use **Apply to selected with Codex**. A Codex worker is launched to inspect each job and attempt the authorized applications. It may stop for a login, CAPTCHA, missing facts, binding agreements, browser access, or other required action. A started worker or populated form does not mean an application was submitted; verify the employer receipt. The feature is experimental and has not been verified end-to-end against a live application.

The worker needs a supported signed-in browser accessible to its Codex environment. A desktop session does not guarantee browser availability. No credentials are stored by this app. Results depend on external services and may require user intervention. The app binds its local service to loopback, checks request origin and a session token, and serializes batches. It has not received an independent security audit. Do not expose its local port to a network.

## Development

Run `python3 -m unittest discover -s tests -v`. No application submission occurs in the test. The desktop app currently depends on `/usr/bin/python3` and the Codex CLI on the local machine. It is ad-hoc signed, not notarized; macOS may require local trust settings. This is a prototype, not an unattended application guarantee.
