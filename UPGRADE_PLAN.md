# ShadowOS Upgrade Plan — v2026.2 "NeonHorizon" → Future Releases

## Overview
This document outlines the phased upgrade roadmap for ShadowOS, covering
immediate fixes, near-term enhancements, and long-term vision items.

---

## Phase 1: Immediate Fixes (v2026.2.1)

### Bug Fixes
- [x] Fix version references in `build-system/build.sh` (was still showing 2026.1)
- [x] Fix ISO output filename to match version 2026.2
- [x] Fix Docker image tag to 2026.2
- [x] Fix VM image references to 2026.2
- [x] Fix help text in build script (BeltrixOS → ShadowOS)

### Security
- [ ] Add Bluetooth security hardening (`rfkill`, `bluetoothctl` policy)
- [ ] Add USBGuard for USB device authorization
- [ ] Implement automatic screen lock after idle timeout
- [ ] Add kernel module signing enforcement

### System Reliability
- [ ] Add power management profiles (laptop/battery optimization)
- [ ] Add system health check script (`shadowos-diagnostics`)
- [ ] Enhance backup script with encryption support
- [ ] Add swapiness tuning for SSD vs HDD detection

---

## Phase 2: Feature Enhancements (v2026.3 "QuantumPulse")

### AI Integration
- [ ] RAG (Retrieval-Augmented Generation) pipeline with local vector store
- [ ] Voice assistant integration (Whisper + TTS via Piper)
- [ ] AI-powered log analysis and anomaly detection
- [ ] Context-aware AI commands (knows current directory, recent files)
- [ ] Multi-model routing (auto-select best model for task type)

### Desktop & UX
- [ ] GUI Control Center (GTK4/Qt6 settings manager)
- [ ] Dynamic wallpaper engine (reacts to time/weather/system state)
- [ ] Notification system integration (dunst/mako with AI summaries)
- [ ] Touchpad gesture support (Wayland)
- [ ] Night mode / blue light filter scheduling

### Developer Experience
- [ ] Pre-configured dev containers for Python, Node, Go, Rust
- [ ] GitHub CLI integration with AI-generated PR descriptions
- [ ] Automated code review pipeline
- [ ] Local CI/CD with Act or Woodpecker
- [ ] Database GUI (DBeaver or pgAdmin)

### Security
- [ ] VPN kill switch with automatic WireGuard reconnection
- [ ] DNS leak protection verification
- [ ] MAC address rotation on network changes
- [ ] File integrity monitoring dashboard
- [ ] Automated vulnerability scanning with OpenVAS

---

## Phase 3: Platform Expansion (v2026.4 "NeuralGrid")

### Cloud Integration
- [ ] AWS/Azure/GCP CLI profiles with assumed roles
- [ ] Terraform/Ansible integration for infrastructure as code
- [ ] Cloud pentesting toolkit (ScoutSuite, Prowler)
- [ ] Container orchestration (Kubernetes CLI, Helm)
- [ ] Serverless deployment templates

### Container & Virtualization
- [ ] Nix/Flakes support for reproducible builds
- [ ] Podman Compose integration
- [ ] LXC/LXD container templates
- [ ] VM snapshot management CLI
- [ ] Cross-compilation toolchains

### Community Ecosystem
- [ ] Plugin system for community contributions
- [ ] Theme marketplace with user-submitted configs
- [ ] Module system for pentest tool categories
- [ ] API for third-party integrations
- [ ] Crowdsourced threat intelligence feeds

---

## Phase 4: Advanced Capabilities (v2026.5+)

### Autonomous Operations
- [ ] Self-healing system (auto-fix common issues)
- [ ] Predictive resource management
- [ ] Automated penetration testing workflows
- [ ] AI-driven firewall rule optimization
- [ ] Behavioral analysis for intrusion detection

### Hardware Support
- [ ] GPU passthrough for VM gaming
- [ ] External GPU (eGPU) auto-configuration
- [ ] Fingerprint reader integration
- [ ] Smart card / YubiKey support
- [ ] Multi-monitor auto-configuration

### Research & Development
- [ ] Local LLM fine-tuning pipeline
- [ ] Custom model training with LoRA
- [ ] Federated learning support
- [ ] Adversarial ML testing tools
- [ ] AI red teaming toolkit

---

## Version History

| Version | Codename | Status | Key Features |
|---------|----------|--------|--------------|
| 2026.1 | NeonVanguard | Released | Base system, KDE, AI integration |
| 2026.2 | NeonHorizon | Released | Enhanced AI, security hardening, ZRAM, Btrfs |
| 2026.3 | QuantumPulse | Planned | RAG, voice assistant, GUI control center |
| 2026.4 | NeuralGrid | Planned | Cloud integration, container ecosystem |
| 2026.5 | TBD | Planned | Autonomous operations, hardware support |

---

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on submitting
enhancements, bug fixes, and new feature requests.