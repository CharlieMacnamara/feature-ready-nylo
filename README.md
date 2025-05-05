### Foundation for core feature development.

1. **Supabase Backend Setup**
   - Complete Supabase tables for core models (already defined in code)
   - Set up essential RLS policies for `user`, `household`, `chore` tables
   - Enable Realtime selectively (only for chores and household data)
   - Test authentication flow end-to-end

2. **Repository Pattern Implementation**
   - Create `ChoreRepository` and `HouseholdRepository` classes
   - Implement standard CRUD methods with proper error handling
   - Utilize `Supabase.instance.client` through dependency injection

3. **Error Handling Standardization**
   - Implement consistent try/catch patterns in repositories
   - Add user-friendly error messages in controllers
   - Use Nylo's toast/dialog system for error feedback
