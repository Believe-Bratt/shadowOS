// ShadowOS Waybar Module — Security Status
// Shows firewall, Tor, VPN, and security service status
// Updated for v2026.2 NeonHorizon

const { exec } = require('child_process');
const { GObject, St, Clutter, GLib } = imports.gi;

class SecurityConfig {
    static get default() {
        return {
            updateInterval: 5,
            format: '🛡️ {firewall} {tor} {vpn} {apparmor}',
            formatSeparator: ' ',
            icons: {
                firewallActive: '🔒',
                firewallInactive: '⚠',
                torActive: '🧅',
                torInactive: '○',
                vpnActive: '🔐',
                vpnInactive: '○',
                apparmorActive: '🛡️',
                apparmorInactive: '○',
                idsActive: '👁',
                idsInactive: '○'
            },
            tooltip: true,
            tooltipFormat: 'Firewall: {firewall}\nTor: {tor}\nVPN: {vpn}\nAppArmor: {apparmor}\nIDS: {ids}'
        };
    }
}

class SecurityStatus extends St.Widget {
    _init(orientation, panel_mode, monitor_index, config) {
        super._init({ style_class: 'security-status' });
        this.orientation = orientation;
        this.config = Object.assign({}, SecurityConfig.default, config);
        this._states = { firewall: false, tor: false, vpn: false, apparmor: false, ids: false };

        // Create label
        this.label = new St.Label({ style_class: 'security-status-label' });
        this.add_child(this.label);

        // Tooltip
        if (this.config.tooltip) {
            this.connect('notify::hover', () => this._updateTooltip());
        }

        // Update loop
        this._update();
        GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, this.config.updateInterval, () => {
            this._update();
            return GLib.SOURCE_CONTINUE;
        });
    }

    _update() {
        // Check firewall (nftables)
        exec('systemctl is-active nftables 2>/dev/null || echo inactive', (err, stdout) => {
            this._states.firewall = stdout.trim() === 'active';
        });

        // Check Tor
        exec('systemctl is-active tor 2>/dev/null || echo inactive', (err, stdout) => {
            this._states.tor = stdout.trim() === 'active';
        });

        // Check VPN (WireGuard)
        exec('wg show 2>/dev/null | grep -c "interface:" || echo 0', (err, stdout) => {
            this._states.vpn = parseInt(stdout.trim()) > 0;
        });

        // Check AppArmor
        exec('systemctl is-active apparmor 2>/dev/null || echo inactive', (err, stdout) => {
            const status = stdout.trim();
            this._states.apparmor = status === 'active' || status === 'enforced';
        });

        // Check IDS (AIDE)
        exec('systemctl is-active aide 2>/dev/null || echo inactive', (err, stdout) => {
            this._states.ids = stdout.trim() === 'active';
        });

        this._refresh();
        return true;
    }

    _refresh() {
        const parts = [];
        if (this._states.firewall) parts.push(this.config.icons.firewallActive);
        if (this._states.tor) parts.push(this.config.icons.torActive);
        if (this._states.vpn) parts.push(this.config.icons.vpnActive);
        if (this._states.apparmor) parts.push(this.config.icons.apparmorActive);
        if (this._states.ids) parts.push(this.config.icons.idsActive);

        const text = parts.length > 0 ? parts.join(this.config.formatSeparator) : this.config.icons.firewallInactive;
        this.label.set_text(text);

        // Tooltip
        if (this.config.tooltip) {
            const tooltip = this.config.tooltipFormat
                .replace('{firewall}', this._states.firewall ? 'ACTIVE 🔒' : 'INACTIVE ⚠')
                .replace('{tor}', this._states.tor ? 'ACTIVE 🧅' : 'INACTIVE ○')
                .replace('{vpn}', this._states.vpn ? 'CONNECTED 🔐' : 'DISCONNECTED ○')
                .replace('{apparmor}', this._states.apparmor ? 'ENFORCED 🛡️' : 'INACTIVE ○')
                .replace('{ids}', this._states.ids ? 'ACTIVE 👁' : 'INACTIVE ○');
            this.set_tooltip_text(tooltip);
        }

        // Color: green if all good, amber if some, red if critical
        const activeCount = [this._states.firewall, this._states.tor, this._states.vpn, this._states.apparmor].filter(Boolean).length;
        if (activeCount >= 4) {
            this.label.style = 'color: #00ff88; font-weight: bold; text-shadow: 0 0 5px #00ff88;';
        } else if (activeCount >= 2) {
            this.label.style = 'color: #ffbf00; font-weight: bold; text-shadow: 0 0 5px #ffbf00;';
        } else {
            this.label.style = 'color: #ff0055; font-weight: bold; text-shadow: 0 0 5px #ff0055;';
        }
    }

    _updateTooltip() {
        // Handled in _refresh
    }
}

// Register module
function registerWaybarModule(metadata) {
    metadata.name = 'security-status';
    metadata.orientation = 'right';
    metadata.defaultConfig = SecurityConfig.default;
    return SecurityStatus;
}
