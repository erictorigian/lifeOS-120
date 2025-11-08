-- LifeOS-120 Seed Data
-- Sample data for development and testing

-- Note: This assumes you have a test user created through Supabase auth
-- Replace 'your-user-id-here' with an actual UUID from auth.users

-- Sample habits
INSERT INTO public.habits (user_id, habit_name, description, target_frequency, category, is_active)
VALUES
    ('00000000-0000-0000-0000-000000000000', 'Drink 8 glasses of water', 'Stay hydrated throughout the day', 'daily', 'hydration', true),
    ('00000000-0000-0000-0000-000000000000', 'Morning meditation', '10 minutes of Silva Method coherence practice', 'daily', 'mental', true),
    ('00000000-0000-0000-0000-000000000000', 'Strength training', 'Resistance exercises for muscle maintenance', '3x per week', 'exercise', true),
    ('00000000-0000-0000-0000-000000000000', 'Gratitude journaling', 'Write 3 things you are grateful for', 'daily', 'mental', true),
    ('00000000-0000-0000-0000-000000000000', '8 hours of sleep', 'Quality sleep for recovery', 'daily', 'sleep', true)
ON CONFLICT DO NOTHING;

-- Note: You can add sample daily entries and lab data here once you have real user IDs
