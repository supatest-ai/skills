# Database Migration Generator

Generate safe, reversible database migrations with proper validation and rollback strategies.

## When to use this skill

Use this skill when you need to:
- Create database schema migrations
- Add or modify database tables
- Create indexes or constraints
- Seed or backfill data
- Plan migration strategies
- Generate rollback scripts

## Instructions

When the user invokes this skill:

1. **Understand the Change**
   - What schema change is needed?
   - What data is being modified?
   - Is this additive or breaking?
   - What's the current schema state?

2. **Analyze Impact**
   - Will this affect existing queries?
   - Is there a performance impact?
   - Does this break existing code?
   - How much data is affected?
   - What's the downtime requirement?

3. **Choose Migration Strategy**
   Based on the change type:

   **Additive Changes** (safe, no downtime)
   - Adding new tables
   - Adding nullable columns
   - Adding indexes (with CONCURRENT)
   - Adding constraints (with validation)

   **Breaking Changes** (requires strategy)
   - Removing columns/tables
   - Changing column types
   - Making columns NOT NULL
   - Renaming columns/tables

   **Recommended approach for breaking changes**:
   1. Expand: Add new structure
   2. Migrate: Dual-write to both
   3. Backfill: Copy old data
   4. Contract: Remove old structure

4. **Generate Migration**

   Create migration with:
   - **Up migration**: Apply the change
   - **Down migration**: Rollback the change
   - **Validation**: Check preconditions
   - **Safety**: Use transactions where possible

   **Example structure** (for most migration tools):
   ```sql
   -- Migration: add_user_avatar_column
   -- Created: 2024-01-15
   -- Description: Add avatar_url column to users table

   -- UP Migration
   BEGIN;

   -- Add column as nullable first (safe)
   ALTER TABLE users
   ADD COLUMN avatar_url TEXT;

   -- Add index if needed for queries
   CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_avatar_url
   ON users(avatar_url) WHERE avatar_url IS NOT NULL;

   -- Add check constraint if needed
   ALTER TABLE users
   ADD CONSTRAINT check_avatar_url_format
   CHECK (avatar_url ~ '^https?://.*');

   COMMIT;

   -- DOWN Migration
   BEGIN;

   -- Remove constraint
   ALTER TABLE users
   DROP CONSTRAINT IF EXISTS check_avatar_url_format;

   -- Remove index
   DROP INDEX IF EXISTS idx_users_avatar_url;

   -- Remove column
   ALTER TABLE users
   DROP COLUMN IF EXISTS avatar_url;

   COMMIT;
   ```

5. **Include Safety Checks**
   - Lock timeouts to prevent long-running locks
   - Validate preconditions (table exists, column doesn't exist, etc.)
   - Use IF EXISTS / IF NOT EXISTS
   - Set statement timeouts
   - Use CONCURRENTLY for indexes (PostgreSQL)

6. **Data Migrations**
   For data changes (backfills, transformations):
   ```sql
   -- Backfill in batches to avoid locking
   DO $$
   DECLARE
     batch_size INTEGER := 1000;
     rows_affected INTEGER;
   BEGIN
     LOOP
       -- Update in batches
       WITH batch AS (
         SELECT id FROM users
         WHERE avatar_url IS NULL
         AND legacy_avatar IS NOT NULL
         LIMIT batch_size
         FOR UPDATE SKIP LOCKED
       )
       UPDATE users
       SET avatar_url = 'https://cdn.example.com/' || legacy_avatar
       FROM batch
       WHERE users.id = batch.id;

       GET DIAGNOSTICS rows_affected = ROW_COUNT;
       EXIT WHEN rows_affected = 0;

       -- Give other transactions a chance
       PERFORM pg_sleep(0.1);
     END LOOP;
   END $$;
   ```

7. **Include Documentation**
   Document:
   - What changed and why
   - Any code changes required
   - Deployment order (DB first vs code first)
   - Expected duration
   - Rollback procedure
   - Monitoring recommendations

8. **Provide Checklist**
   ```markdown
   ## Deployment Checklist
   - [ ] Back up database (for large changes)
   - [ ] Test migration on staging
   - [ ] Verify down migration works
   - [ ] Update ORM models/schema
   - [ ] Update API types
   - [ ] Deploy code that's compatible with both old and new schema
   - [ ] Run migration
   - [ ] Monitor for errors
   - [ ] Deploy code that requires new schema (if applicable)
   - [ ] Remove old code/columns (if multi-step migration)
   ```

## Examples

### Example 1: Add a New Column
```
User: "I need to add an email_verified column to users"

You:
# Migration: Add email_verified Column

## Overview
Adds a boolean column to track email verification status.

## Migration File
```sql
-- migrations/2024011501_add_email_verified.sql

-- UP
BEGIN;

-- Add column with default false (safe, no null values)
ALTER TABLE users
ADD COLUMN email_verified BOOLEAN NOT NULL DEFAULT false;

-- Add index for common query pattern
CREATE INDEX CONCURRENTLY idx_users_email_verified
ON users(email_verified)
WHERE email_verified = false;

-- Optionally verify existing users with confirmed emails
UPDATE users
SET email_verified = true
WHERE email_confirmed_at IS NOT NULL;

COMMIT;

-- DOWN
BEGIN;

DROP INDEX IF EXISTS idx_users_email_verified;

ALTER TABLE users
DROP COLUMN email_verified;

COMMIT;
```

## Deployment Notes
- ✅ Zero downtime - column added with default
- ✅ Code can deploy before or after migration
- ⚠️ Index creation may take time on large tables (use CONCURRENTLY)
- 📝 Update User model to include email_verified field

## Code Changes Needed
```typescript
// Update User type
interface User {
  id: string;
  email: string;
  email_verified: boolean; // Add this
  // ...
}
```
```

### Example 2: Breaking Change (Column Rename)
```
User: "Rename 'created' column to 'created_at' in posts table"

You:
# Migration: Rename created to created_at (3-step)

⚠️ This is a breaking change requiring a multi-step deployment.

## Step 1: Add New Column
```sql
-- migrations/2024011501_add_created_at.sql
BEGIN;

-- Add new column, copy data
ALTER TABLE posts
ADD COLUMN created_at TIMESTAMP;

UPDATE posts
SET created_at = created
WHERE created_at IS NULL;

-- Make NOT NULL after backfill
ALTER TABLE posts
ALTER COLUMN created_at SET NOT NULL;

COMMIT;
```

**Deploy**: Update code to write to BOTH columns

## Step 2: Dual Write Period
- Application writes to both 'created' and 'created_at'
- Backfill any missed data
- Monitor for a few days

## Step 3: Remove Old Column
```sql
-- migrations/2024011502_remove_created.sql
BEGIN;

ALTER TABLE posts
DROP COLUMN created;

COMMIT;
```

**Deploy**: Update code to only use 'created_at'

## Alternative: Simple Rename (requires downtime)
If downtime is acceptable:
```sql
BEGIN;
ALTER TABLE posts
RENAME COLUMN created TO created_at;
COMMIT;
```
- Downtime required while migration runs
- Deploy code immediately after migration
```

### Example 3: Add Index
```
User: "Users query by email is slow, we need an index"

You:
# Migration: Add Email Index

```sql
-- migrations/2024011501_add_users_email_index.sql

-- UP
-- Use CONCURRENTLY to avoid locking table (PostgreSQL)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_email
ON users(email);

-- Analyze table after index creation
ANALYZE users;

-- DOWN
DROP INDEX CONCURRENTLY IF EXISTS idx_users_email;
```

## Notes
- ✅ Zero downtime with CONCURRENTLY
- ⚠️ CONCURRENTLY cannot run in transaction block
- ⏱️ May take several minutes on large tables
- 📊 Monitor: `SELECT * FROM pg_stat_progress_create_index;`
```

## Tips

- **Test migrations thoroughly**: Always test up AND down migrations
- **Use transactions**: Wrap in BEGIN/COMMIT when possible
- **Be conservative**: Prefer multiple safe migrations over one risky one
- **Consider scale**: What works for 1K rows may not work for 1M
- **Use CONCURRENTLY**: For indexes and some ALTER TABLE operations (PostgreSQL)
- **Batch large updates**: Don't lock tables for long periods
- **Document everything**: Future you will thank you
- **Plan rollbacks**: Know how to undo the change
- **Monitor after deployment**: Watch for slow queries, errors
- **Version your schema**: Keep schema in sync with code

## Database-Specific Notes

**PostgreSQL**
- Use `CONCURRENTLY` for index creation
- Use `SET statement_timeout` for safety
- Use `pg_stat_progress_create_index` to monitor

**MySQL**
- Use `ALGORITHM=INPLACE` when possible
- Be cautious with `ALTER TABLE` on large tables
- Consider `pt-online-schema-change` for large tables

**SQLite**
- Limited ALTER TABLE support
- May need to recreate table for some changes
- Always in transaction

## Notes

- Always prefer additive changes over breaking ones
- Use feature flags for code that depends on new schema
- Consider impact on running queries during migration
- Have a rollback plan before deploying
- Test on production-like data volumes
