# Everlearn Install Guide

## 1. Install Or Download

Fast install/update from GitHub:

```bash
curl -fsSL https://raw.githubusercontent.com/tripleyak/everlearn/v2026-05-27-workshop/scripts/install.sh | bash -s -- --ref v2026-05-27-workshop --profile ecommerce
```

This downloads the latest package, runs setup, and verifies the install.

To pin a specific release or branch:

```bash
curl -fsSL https://raw.githubusercontent.com/tripleyak/everlearn/v2026-05-27-workshop/scripts/install.sh | bash -s -- --ref v2026-05-27-workshop --profile ecommerce
```

Manual ZIP install:

If you received `everlearn-workshop.zip`:

```bash
cd ~/Downloads
unzip everlearn-workshop.zip
cd everlearn
```

If you cloned the project from GitHub:

```bash
cd ~/Projects/everlearn
```

## 2. Run Setup For Manual ZIP Installs

For the ecommerce workshop:

```bash
./scripts/setup.sh --profile ecommerce
```

For a general personal knowledge vault:

```bash
./scripts/setup.sh --profile general
```

To choose a different vault path:

```bash
./scripts/setup.sh --profile general --vault "$HOME/Documents/My Knowledge Vault"
```

## 3. Verify

```bash
~/.everlearn/bin/everlearn verify
```

You should see checks for the vault, local config, command wrapper, and agent skill folders.

## 4. Capture A Test Note

```bash
~/.everlearn/bin/everlearn capture \
  --type learning \
  --title "Everlearn setup works" \
  "I installed Everlearn and confirmed that notes are being written to my local vault."
```

Open the vault in Obsidian:

1. Open Obsidian.
2. Choose `Open folder as vault`.
3. Select `~/Everlearn Vault`.

## 5. Use From Claude Code Or Codex

After setup, ask Claude Code or Codex:

```text
Use Everlearn to capture the reusable learning from this session.
```

or:

```text
Save this as an Everlearn decision note in my vault.
```

In Claude Code, you can also use:

```text
/everlearn signal Customers keep asking whether the starter bundle includes replacement filters.
```

In Codex, you can use:

```text
/everlearn signal Customers keep asking whether the starter bundle includes replacement filters.
```

If your Codex install does not expose skill slash commands, use the natural-language prompt above. Everlearn also installs an `everlearn` prompt shortcut for Codex versions that expose prompt shortcuts.

## Optional: SignalSweep Inside Everlearn

If SignalSweep is installed, Everlearn can run it and save that run into the Everlearn vault without changing SignalSweep's normal default save directory.

```bash
~/.everlearn/bin/everlearn signalsweep \
  --topic "customer complaints about cold plunge accessories" \
  -- --quick
```

The raw SignalSweep artifact goes to:

```text
~/Everlearn Vault/30 Research/SignalSweep
```

The distilled Everlearn note goes to:

```text
~/Everlearn Vault/30 Research
```

## Troubleshooting

### `everlearn: command not found`

Use the full path:

```bash
~/.everlearn/bin/everlearn verify
```

To make `everlearn` available in new terminal windows:

```bash
echo 'export PATH="$HOME/.everlearn/bin:$PATH"' >> ~/.zshrc
```

Then open a new terminal.

### The vault did not appear in Obsidian

Obsidian does not auto-open new folders. Open Obsidian and select `Open folder as vault`, then choose `~/Everlearn Vault` or the custom path you used during setup.

### Claude Code or Codex does not notice the skill

Restart the agent app or terminal session after setup. Then ask for Everlearn by name.

### I want a different default profile

Run setup again:

```bash
./scripts/setup.sh --profile research
```

This updates `~/.everlearn/config` and leaves your existing notes in place.
