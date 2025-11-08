-- LifeOS-120 Initial Database Schema
-- This migration creates the core tables for health and longevity tracking
-- Using gen_random_uuid() which is built into PostgreSQL 13+

-- ============================================================================
-- USERS TABLE (extends Supabase auth.users)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    date_of_birth DATE,
    target_age INTEGER DEFAULT 120,
    height_cm DECIMAL(5,2),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Users can only read/update their own profile
CREATE POLICY "Users can view own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

-- ============================================================================
-- DAILY ENTRIES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.daily_entries (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    entry_date DATE NOT NULL,

    -- Hydration
    water_ml INTEGER DEFAULT 0,

    -- Nutrition (simplified)
    calories INTEGER,
    protein_g DECIMAL(6,2),
    carbs_g DECIMAL(6,2),
    fats_g DECIMAL(6,2),

    -- Exercise
    exercise_minutes INTEGER DEFAULT 0,
    exercise_type TEXT,
    steps INTEGER,

    -- Sleep
    sleep_hours DECIMAL(4,2),
    sleep_quality INTEGER CHECK (sleep_quality >= 1 AND sleep_quality <= 10),

    -- Mental/Emotional
    gratitude_entry TEXT,
    coherence_practice_minutes INTEGER DEFAULT 0,
    mood_score INTEGER CHECK (mood_score >= 1 AND mood_score <= 10),

    -- Journal
    notes TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Ensure one entry per user per day
    UNIQUE(user_id, entry_date)
);

ALTER TABLE public.daily_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own entries"
    ON public.daily_entries FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own entries"
    ON public.daily_entries FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own entries"
    ON public.daily_entries FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own entries"
    ON public.daily_entries FOR DELETE
    USING (auth.uid() = user_id);

-- Index for faster queries
CREATE INDEX idx_daily_entries_user_date ON public.daily_entries(user_id, entry_date DESC);

-- ============================================================================
-- LAB DATA TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.lab_data (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    test_date DATE NOT NULL,
    test_name TEXT NOT NULL,

    -- Common biomarkers
    value DECIMAL(10,4),
    unit TEXT,
    reference_range_low DECIMAL(10,4),
    reference_range_high DECIMAL(10,4),

    -- Additional context
    lab_provider TEXT,
    notes TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.lab_data ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own lab data"
    ON public.lab_data FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own lab data"
    ON public.lab_data FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own lab data"
    ON public.lab_data FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own lab data"
    ON public.lab_data FOR DELETE
    USING (auth.uid() = user_id);

CREATE INDEX idx_lab_data_user_date ON public.lab_data(user_id, test_date DESC);

-- ============================================================================
-- HABITS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.habits (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    habit_name TEXT NOT NULL,
    description TEXT,
    target_frequency TEXT, -- e.g., "daily", "3x per week"
    category TEXT, -- e.g., "exercise", "nutrition", "mental", "sleep"
    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.habits ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own habits"
    ON public.habits FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own habits"
    ON public.habits FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own habits"
    ON public.habits FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own habits"
    ON public.habits FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================================================
-- HABIT COMPLETIONS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.habit_completions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    habit_id UUID REFERENCES public.habits(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    completion_date DATE NOT NULL,
    completed BOOLEAN DEFAULT TRUE,
    notes TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(habit_id, completion_date)
);

ALTER TABLE public.habit_completions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own habit completions"
    ON public.habit_completions FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own habit completions"
    ON public.habit_completions FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own habit completions"
    ON public.habit_completions FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own habit completions"
    ON public.habit_completions FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================================================
-- FUNCTIONS & TRIGGERS
-- ============================================================================

-- Automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_daily_entries_updated_at BEFORE UPDATE ON public.daily_entries
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_lab_data_updated_at BEFORE UPDATE ON public.lab_data
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_habits_updated_at BEFORE UPDATE ON public.habits
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Automatically create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name)
    VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'full_name');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
