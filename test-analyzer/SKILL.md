# Test Analyzer

Analyze failing tests from Supatest runs and provide comprehensive debugging context with fix suggestions.

## When to use this skill

Use this skill when you need to:
- Debug failing tests from a Supatest run
- Understand why tests are breaking
- Get fix suggestions for test failures
- Analyze patterns in test failures
- Review test execution history

## Instructions

When the user invokes this skill:

1. **Identify the Test Context**
   - Ask for the test run ID or test IDs if not provided
   - If user mentions "latest failures" or "recent run", fetch the most recent run

2. **Gather Test Failure Data**
   Use the Supatest MCP tools to collect information:

   ```
   # Get recent test runs
   mcp__supatest__get-runs with appropriate filters

   # Get failing tests from a specific run
   mcp__supatest__get-failing-tests with the runId

   # Get detailed context for fixing tests
   mcp__supatest__get-fix-context with array of testIds
   ```

3. **Analyze Each Failure**
   For each failing test, examine:
   - **Error message**: What specifically failed?
   - **Stack trace**: Where in the code did it fail?
   - **Execution steps**: What led to the failure?
   - **Console output**: Any relevant logs or warnings?
   - **Historical data**: Has this test failed before? Is this a flaky test?

4. **Identify Patterns**
   Look for:
   - Common error types across multiple tests
   - Shared setup or teardown issues
   - Environment-specific failures
   - Timing or race condition patterns
   - Recent code changes that might have caused breakage

5. **Generate Analysis Report**
   Create a structured report with:

   **Executive Summary**
   - Total failing tests
   - Overall pass/fail rate
   - Critical patterns identified

   **Test Failures by Category**
   Group failures by:
   - Error type (assertion, timeout, network, etc.)
   - Affected module/feature
   - Severity (blocking vs flaky)

   **Individual Test Analysis**
   For each significant failure:
   ```
   ### Test: [Test Name] (TS-XXX)
   **File**: path/to/test/file.spec.ts
   **Status**: Failed
   **Error**: Clear error message

   **Root Cause Analysis**:
   - What went wrong
   - Why it happened
   - Related code changes

   **Recommended Fix**:
   - Specific steps to fix
   - Code changes needed
   - Alternative approaches

   **Historical Context**:
   - Pass rate: X%
   - Recent failures: X times in last Y runs
   - Flaky indicator: Yes/No
   ```

   **Flaky Tests Alert**
   - List tests with inconsistent pass/fail history
   - Suggest stabilization approaches

   **Recommended Actions**
   Prioritized list:
   1. Critical fixes (blocking functionality)
   2. Likely quick wins (obvious fixes)
   3. Requires investigation (complex issues)
   4. Flaky test stabilization

6. **Provide Code Context**
   - Read the relevant test files
   - Review the code being tested
   - Check recent git changes to related files
   - Show relevant code snippets with line numbers

7. **Suggest Fixes**
   For each failure, provide:
   - **Immediate fix**: What to change right now
   - **Root cause fix**: Address underlying issue
   - **Prevention**: How to avoid similar failures
   - **Code examples**: Concrete fix implementations

8. **Offer Next Steps**
   - Ask if user wants to fix specific tests
   - Offer to create a fix plan
   - Suggest test improvements
   - Recommend additional investigation areas

## Examples

### Example 1: Analyze Recent Failures
```
User: "What tests are failing in the latest run?"

You:
1. Call mcp__supatest__get-runs to get the latest run
2. Call mcp__supatest__get-failing-tests with the runId
3. Call mcp__supatest__get-fix-context for detailed info
4. Respond with:

# Test Failure Analysis - Run RN-1234

## Summary
- **Total Tests**: 156
- **Failures**: 8 (5.1%)
- **Pass Rate**: 94.9%
- **Run**: RN-1234 (main branch)

## Critical Issues (3)

### 1. Authentication Test Suite Failures
**Tests Affected**: 3 tests
- `auth.spec.ts:45` - User login with valid credentials
- `auth.spec.ts:67` - Token refresh flow
- `auth.spec.ts:89` - Session persistence

**Common Error**: `TypeError: Cannot read property 'token' of undefined`

**Root Cause**: Recent API change modified the auth response structure from:
```typescript
// Old
{ token: "...", user: {...} }
// New
{ data: { token: "...", user: {...} } }
```

**Fix**: Update auth test helpers to access `response.data.token` instead of `response.token`

**Files to Update**:
- tests/helpers/auth.ts:23
- tests/auth.spec.ts (3 locations)

## Flaky Tests (2)

### Test: "Dashboard loads user stats" (TS-456)
- **Pass Rate**: 78% (7/9 recent runs)
- **Issue**: Race condition in data loading
- **Fix**: Add proper wait for data loading completion
- **Suggested Change**: Replace `waitFor(element)` with `waitForLoadingToComplete()`
```

### Example 2: Deep Dive on Specific Test
```
User: "Why is TS-789 failing?"

You:
1. Call mcp__supatest__get-test-details with testId TS-789
2. Read the test file
3. Review related source code
4. Check git history
5. Respond with detailed analysis and fix
```

## Tips

- **Start with the big picture**: Show summary before diving into details
- **Prioritize by impact**: Critical failures before flaky tests
- **Show, don't just tell**: Include relevant code snippets
- **Provide actionable fixes**: Concrete steps, not vague suggestions
- **Use historical data**: Leverage pass/fail patterns to identify flaky tests
- **Link related issues**: Connect failures that have the same root cause
- **Offer to implement fixes**: Don't just analyze, offer to fix if user wants
- **Check git blame**: Recent changes often cause new failures

## Integration with Supatest MCP

This skill leverages the Supatest MCP server tools:
- `get-runs`: List recent test runs with filtering
- `get-failing-tests`: Get failing tests from a specific run
- `get-test-details`: Get detailed info about a specific test
- `get-fix-context`: Get rich formatted context for fixing tests

Always use these tools to get accurate, real-time test data.

## Notes

- This skill works best when you have access to the actual test code
- Offer to read test files and source code to provide better context
- When suggesting fixes, always show the actual code changes needed
- If a test is consistently flaky, recommend removing or rewriting it
- Consider running the tests locally if more investigation is needed
