# PR Review

Perform comprehensive code reviews following Supatest's standards and best practices.

## When to use this skill

Use this skill when you need to:
- Review a pull request thoroughly
- Provide structured feedback on code changes
- Check for common issues and anti-patterns
- Ensure code meets team standards
- Give constructive feedback to teammates

## Instructions

When the user invokes this skill:

1. **Get PR Information**
   - If a PR number or URL is provided, fetch it: `gh pr view <number>`
   - If reviewing local changes, use git diff: `git diff main...HEAD`
   - Get the list of changed files: `gh pr diff <number>` or `git diff --name-only`

2. **Review Scope**
   Understand what's being changed:
   - Read the PR description and objectives
   - Note the type of change (feature, bugfix, refactor, etc.)
   - Check linked issues or tickets
   - Review the file change summary

3. **Code Quality Review**
   Examine the code for:

   **Architecture & Design**
   - Is the approach sound and maintainable?
   - Are there better alternatives?
   - Does it follow established patterns?
   - Is the scope appropriate (not too large/small)?

   **Code Quality**
   - Clear, readable, and self-documenting
   - Proper naming conventions
   - Appropriate abstractions (not over/under-engineered)
   - DRY principle without premature abstraction
   - Error handling and edge cases
   - Performance considerations

   **Security**
   - Input validation and sanitization
   - Authentication and authorization checks
   - No hardcoded secrets or credentials
   - SQL injection, XSS, CSRF protections
   - Secure data handling

   **Testing**
   - Are there tests for new functionality?
   - Do tests cover edge cases?
   - Are existing tests updated?
   - Test quality and maintainability

   **Documentation**
   - Complex logic explained
   - API changes documented
   - README updates if needed
   - Breaking changes noted

4. **Supatest-Specific Checks**
   - Test code follows Supatest patterns
   - Proper use of test utilities and helpers
   - Database migrations if schema changes
   - API endpoint versioning if applicable
   - TypeScript types properly defined

5. **Git & PR Hygiene**
   - Commits are logical and well-messaged
   - No merge commits (should be rebased)
   - No unrelated changes
   - No debug code or console.logs
   - Dependencies properly justified

6. **Generate Review**
   Structure the review as:

   **Summary**
   - Overall assessment (Approve / Request Changes / Comment)
   - High-level feedback
   - Major concerns or compliments

   **Strengths** 🎉
   - What's done well
   - Good practices observed
   - Clever solutions

   **Issues Found**
   Categorized by severity:

   **🚨 Critical** (Must fix)
   - Security vulnerabilities
   - Breaking changes without migration
   - Data loss risks
   - Major bugs

   **⚠️ Important** (Should fix)
   - Logic errors
   - Missing error handling
   - Performance issues
   - Missing tests for critical paths

   **💡 Suggestions** (Consider)
   - Code improvements
   - Better naming
   - Refactoring opportunities
   - Additional tests

   **🎨 Nitpicks** (Optional)
   - Style inconsistencies
   - Minor optimizations
   - Documentation tweaks

   **Detailed Comments**
   For each issue, provide:
   ```
   File: path/to/file.ts:42

   Issue: [Brief description]

   Current code:
   ```typescript
   // problematic code
   ```

   Suggested fix:
   ```typescript
   // improved code
   ```

   Rationale: [Why this is better]
   ```

   **Questions**
   - Clarifications needed
   - Design decisions to discuss
   - Alternative approaches to consider

   **Action Items**
   Clear checklist of what needs to be done:
   - [ ] Fix security issue in auth handler
   - [ ] Add tests for error cases
   - [ ] Update API documentation
   - [ ] Remove debug logging

7. **Tone & Approach**
   - Be constructive and respectful
   - Explain the "why" behind suggestions
   - Offer specific solutions, not just problems
   - Balance criticism with praise
   - Ask questions rather than make demands
   - Consider the PR author's skill level

8. **Final Recommendation**
   - **Approve**: Ready to merge, minor or no issues
   - **Approve with comments**: Can merge, but consider suggestions
   - **Request changes**: Must address issues before merging
   - **Comment**: Questions or discussion needed

## Examples

### Example 1: Feature PR Review
```
User: "Review PR #456"

You: Fetch and review the PR, then respond:

# PR Review: Add User Avatar Upload (#456)

## Summary
This PR adds user avatar upload functionality with S3 storage. The implementation is solid overall, but there are a few security and error handling concerns that should be addressed before merging.

**Recommendation**: Request Changes ⚠️

## Strengths 🎉
- Excellent test coverage (95%+)
- Clean separation of concerns with dedicated upload service
- Proper TypeScript types throughout
- Good error messages for users

## Issues Found

### 🚨 Critical

**File: `src/services/upload.ts:23`**
```typescript
// Current - No file type validation
const uploadFile = async (file: File) => {
  return await s3.upload(file);
}

// Suggested
const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'image/webp'];
const MAX_SIZE = 5 * 1024 * 1024; // 5MB

const uploadFile = async (file: File) => {
  if (!ALLOWED_TYPES.includes(file.type)) {
    throw new Error('Invalid file type');
  }
  if (file.size > MAX_SIZE) {
    throw new Error('File too large');
  }
  return await s3.upload(file);
}
```
**Rationale**: Without validation, users could upload executable files or extremely large files, causing security and performance issues.

### ⚠️ Important

**File: `src/api/avatar.ts:45`**
Missing error handling for S3 failures. Should catch and return user-friendly errors.

**File: `tests/avatar.spec.ts`**
No tests for:
- File size limits
- Invalid file types
- S3 upload failures
- Concurrent uploads by same user

### 💡 Suggestions

**File: `src/services/upload.ts:67`**
Consider generating thumbnails for avatars to improve load times:
```typescript
const processAvatar = async (file: File) => {
  const optimized = await sharp(file)
    .resize(200, 200)
    .jpeg({ quality: 80 })
    .toBuffer();
  return optimized;
}
```

## Questions
1. Should we support animated GIFs?
2. What happens to old avatars when users upload new ones? (cleanup?)
3. Is there rate limiting on uploads?

## Action Items
- [ ] Add file type and size validation
- [ ] Add error handling for S3 failures
- [ ] Add tests for edge cases
- [ ] Document supported file types in API docs
- [ ] Consider adding cleanup for old avatars
```

### Example 2: Quick Review
```
User: "Quick review of my changes"

You: Review local git diff and provide concise feedback:

# Code Review: Local Changes

## Summary
Clean refactoring of the auth service. No blocking issues, but a few suggestions.

**Recommendation**: Approve with comments ✅

## Strengths 🎉
- Much better separation of concerns
- Improved error messages
- Good use of TypeScript types

## 💡 Suggestions
1. Consider extracting token validation to a separate helper
2. Add JSDoc for the public methods
3. One test is missing for the expired token case

Overall looks good! The suggestions are minor and can be addressed later if needed.
```

## Tips

- **Read the whole PR first**: Get context before diving into details
- **Prioritize feedback**: Critical issues first, nitpicks last
- **Be specific**: Point to exact lines and provide code examples
- **Explain reasoning**: Help the author learn, don't just criticize
- **Offer solutions**: Don't just point out problems
- **Consider context**: A prototype needs different review than production code
- **Check the tests**: Good tests are as important as good code
- **Look for patterns**: Multiple similar issues might indicate a bigger problem
- **Positive feedback matters**: Call out good work, not just problems
- **Time-box large PRs**: For huge PRs, focus on architecture and major issues

## Notes

- Adjust depth of review based on PR size and complexity
- For very large PRs (>500 lines), suggest breaking it up
- If you're unsure about something, ask questions rather than assuming
- Remember that code review is a learning opportunity for everyone
- Focus on meaningful issues, not personal style preferences
- Consider using `git diff` or `gh pr diff` to see actual changes
