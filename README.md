Ensure players are on the correct Steam beta branch for your Garry's Mod server!

🧩 Features
Automatically checks the player's Steam beta branch when they join the server.
Shows a warning in chat if the client's branch differs from the server's.
Periodically reminds the player to switch branches (customizable interval).
Two types of messages:
- Player is not on the beta, server is → Suggests joining the beta.
- Player is on the wrong beta → Suggests switching to correct one.
Lightweight and easy to configure via JSON.

⚙️ Configuration
A config file is created at:
`garrysmod/data/branch_reminder_config.json`

Change the `interval` value (in seconds) to modify how often reminders are shown.

✅ Use Case
If your server runs on a specific Steam beta branch like "x86-64", you can prevent players from experiencing issues due to mismatched versions by reminding them to switch to the correct one.

💡 Notes
- The reminder only triggers if the player's branch differs from the server's.
- Messages are shown in the in-game chat.
- Clean and minimal implementation using native GMod functions.

Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=3542802362
