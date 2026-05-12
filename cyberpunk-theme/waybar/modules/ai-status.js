// ============================================================================
// ShadowOS Waybar Module — AI Status
// ============================================================================
// Shows Ollama AI engine status and active model
// ============================================================================

const { exec } = require('child_process');
const { GObject, St, Clutter, GLib } = imports.gi;

class AIConfig {
    static get default() {
        return {
            updateInterval: 2,
            format: '🤖 {icon} {status}',
            formatRunning: '🤖 {icon} {model}',
            formatStopped: '🤖 STOPPED',
            iconRunning: '●',
            iconStopped: '○',
            tooltip: true,
            tooltipFormat: 'AI Engine: {status}\nModel: {model}\nUptime: {uptime}'
        };
    }
}

class AIStatus extends St.Widget {
    _init(orientation, panel_mode, monitor_index, config) {
        super._init({ style_class: 'ai-status' });
        this.orientation = orientation;
        this.config = Object.assign({}, AIConfig.default, config);
        this._status = 'stopped';
        this._model = 'None';
        this._uptime = 0;
        this._startTime = null;

        // Create label
        this.label = new St.Label({ style_class: 'ai-status-label' });
        this.add_child(this.label);

        // Tooltip
        if (this.config.tooltip) {
            this.connect('notify::hover', () => this._updateTooltip());
            this.connect('notify::tooltip-text', () => this._updateTooltip());
        }

        // Update loop
        this._update();
        GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, this.config.updateInterval, () => {
            this._update();
            return GLib.SOURCE_CONTINUE;
        });
    }

    _update() {
        exec('systemctl is-active ollama 2>/dev/null || echo stopped', (err, stdout) => {
            const status = stdout.trim();
            if (status === 'active') {
                this._status = 'running';
                if (!this._startTime) this._startTime = Date.now();
                // Get current model
                exec('ollama ps 2>/dev/null | head -1 | awk \'{print $1}\'', (e, model) => {
                    this._model = model.trim() || 'Unknown';
                });
            } else {
                this._status = 'stopped';
                this._startTime = null;
                this._model = 'None';
            }
            this._refresh();
        });
        return true;
    }

    _refresh() {
        let text, tooltip;
        if (this._status === 'running') {
            text = this.config.formatRunning
                .replace('{icon}', this.config.iconRunning)
                .replace('{model}', this._model);
            tooltip = this.config.tooltipFormat
                .replace('{status}', 'ONLINE')
                .replace('{model}', this._model)
                .replace('{uptime}', this._formatUptime());
        } else {
            text = this.config.formatStopped;
            tooltip = this.config.tooltipFormat
                .replace('{status}', 'OFFLINE')
                .replace('{model}', 'N/A')
                .replace('{uptime}', 'N/A');
        }
        this.label.set_text(text);
        this.set_tooltip_text(tooltip);

        // Neon color based on status
        if (this._status === 'running') {
            this.label.style = 'color: #00ffff; font-weight: bold; text-shadow: 0 0 5px #00ffff;';
        } else {
            this.label.style = 'color: #666677; font-weight: normal;';
        }
    }

    _formatUptime() {
        if (!this._startTime) return 'N/A';
        const seconds = Math.floor((Date.now() - this._startTime) / 1000);
        const hrs = Math.floor(seconds / 3600);
        const mins = Math.floor((seconds % 3600) / 60);
        return `${hrs}h ${mins}m`;
    }

    _updateTooltip() {
        // Tooltip updated in _refresh
    }
}

// Register module
function registerWaybarModule(metadata) {
    metadata.name = 'ai-status';
    metadata.orientation = 'right';
    metadata.defaultConfig = AIConfig.default;
    return AIStatus;
}  
