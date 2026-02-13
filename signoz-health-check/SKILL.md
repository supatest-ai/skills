---
name: signoz-health-check
description: Check broad metrics and health status of SigNoz observability platform. Shows service health, error rates, latency, recent errors, and alerts. Use when you need to monitor system health or investigate issues.
user_invocable: true
---

# SigNoz Health Check

Perform a comprehensive health check of the SigNoz observability platform, analyzing services, logs, metrics, traces, and alerts to identify highlights and issues.

## Usage

```
/signoz-health-check [timeRange]
```

Examples:
- `/signoz-health-check` -- Check last 24 hours (default)
- `/signoz-health-check 1h` -- Check last 1 hour
- `/signoz-health-check 6h` -- Check last 6 hours
- `/signoz-health-check 7d` -- Check last 7 days

## What It Checks

### 1. Service Health
- List all active services
- Call rates and request volumes
- Error rates (identify services with >0% errors)
- P99 latency metrics
- Top operations per service

### 2. Error Analysis
- Recent ERROR/FATAL logs across all services
- Error patterns and frequency
- Services most affected by errors
- Common error messages

### 3. Traces
- Error traces for high-error services
- Slow traces (P99 > threshold)
- Trace patterns and bottlenecks

### 4. Alerts
- Active alerts currently firing
- Alert frequency and patterns
- Services with no alerts configured (risk)

### 5. Metrics
- Available metric keys
- Key performance indicators
- Resource utilization patterns

### 6. Dashboards
- List of configured dashboards
- Coverage gaps

## Output Format

The check produces a structured report with:

### Highlights
- ✅ Well-performing services (0% error rate)
- 📊 High traffic endpoints
- 🎯 Key metrics and thresholds met

### Issues
- 🔴 **Critical**: Services with high error rates (>1%)
- 🟡 **Warning**: Recurring errors or performance degradation
- 🟠 **Attention**: Missing alerts or monitoring gaps

### Recommendations
- Immediate actions required
- Monitoring improvements needed
- Performance optimizations to consider

## Time Range Format

Supported formats:
- `30m`, `1h`, `2h`, `6h` -- Hours/minutes
- `24h`, `7d` -- Days
- Default: `24h` (24 hours)

## Prerequisites

- SigNoz MCP server must be configured and connected
- Access to SigNoz API required

## Example Output

```
# SigNoz Health Check - Last 24 Hours

## 📊 System Overview
- 5 active services
- 141,588 total requests
- 103 errors (0.07% overall)

## ✅ Highlights
- api: 103,878 calls, 0% errors
- ws-server: 13,268 calls, 0% errors
- 6 dashboards configured

## ⚠️ Issues
🔴 code-api: 1.98% error rate (103/5,200 calls)
   - P99 latency: 56.8s
   - Error: Session errors on POST /v1/sessions/:sessionId/v1/messages

🟡 Recurring errors:
   - "Test case not found" - 30+ occurrences
   - "Failed to ensure TTLs on job tracker keys" - Every 5 minutes

## 💡 Recommendations
1. Investigate code-api session errors immediately
2. Create alerts for error rate > 1%
3. Fix Redis TTL management issues
```

## How It Works

1. **Query services**: Get all active services for the time range
2. **Check alerts**: List active and historical alerts
3. **Analyze logs**: Query error logs (ERROR/FATAL severity)
4. **Inspect traces**: Sample error traces from high-error services
5. **Review metrics**: Check available metrics and dashboards
6. **Synthesize**: Combine data into actionable insights

## Common Issues

### "No services found"
- Check SigNoz is running and instrumentation is active
- Verify the time range has data

### "MCP server not connected"
- Ensure SigNoz MCP server is configured in Claude settings
- Check network connectivity to SigNoz

### "Incomplete data"
- Some services may not have full instrumentation
- Check for dataWarning fields indicating overflow

## Integration with Other Skills

This skill complements:
- Investigation workflows (drill into specific errors)
- Alerting setup (identify missing alerts)
- Performance optimization (find bottlenecks)

## Key Metrics Tracked

| Metric | Threshold | Action |
|--------|-----------|--------|
| Error rate | >1% | Critical investigation |
| P99 latency | >10s | Performance review |
| Alert count | 0 configured | Add monitoring |
| Recurring errors | >10/hour | Root cause analysis |

## When to Use

- **Regular health checks**: Run daily or weekly
- **Incident investigation**: Start with this to get context
- **Performance reviews**: Identify optimization opportunities
- **Capacity planning**: Understand traffic patterns
- **Post-deployment**: Verify system health after changes

## Advanced Usage

The skill collects data that can be further analyzed:
- Correlate error spikes with deployments
- Track error rate trends over time
- Identify cascade failures across services
- Monitor specific error patterns

For deeper investigation of specific issues, use:
- `mcp__signoz__signoz_get_trace_details` for trace analysis
- `mcp__signoz__signoz_search_logs_by_service` for detailed logs
- `mcp__signoz__signoz_get_alert_history` for alert patterns
