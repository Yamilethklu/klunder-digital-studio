-- Klunder Digital Studio: ejecutar en Supabase SQL Editor
create table if not exists public.admins (user_id uuid primary key references auth.users(id) on delete cascade);
create table if not exists public.jobs (
 id uuid primary key default gen_random_uuid(),
 name text not null, client text not null,
 amount numeric(12,2) not null check(amount >= 0),
 paid numeric(12,2) not null default 0 check(paid >= 0 and paid <= amount),
 status text not null default 'En proceso',
 created_at timestamptz not null default now()
);
create table if not exists public.portfolio (
 id uuid primary key default gen_random_uuid(),
 name text not null, category text not null,
 description text not null, image text default '', link text default '',
 created_at timestamptz not null default now()
);
create table if not exists public.quotes (
 id uuid primary key default gen_random_uuid(),
 name text not null, email text not null, service text not null,
 message text not null, created_at timestamptz not null default now()
);
alter table public.admins enable row level security;
alter table public.jobs enable row level security;
alter table public.portfolio enable row level security;
alter table public.quotes enable row level security;
create or replace function public.is_studio_admin() returns boolean language sql stable security definer set search_path = '' as $$
 select exists(select 1 from public.admins where user_id = (select auth.uid()))
$$;
revoke all on function public.is_studio_admin() from public;
grant execute on function public.is_studio_admin() to authenticated, anon;
drop policy if exists "admin_self" on public.admins;
create policy "admin_self" on public.admins for select to authenticated using(user_id = (select auth.uid()));
drop policy if exists "admin_jobs" on public.jobs;
create policy "admin_jobs" on public.jobs for all to authenticated using(public.is_studio_admin()) with check(public.is_studio_admin());
drop policy if exists "public_portfolio_read" on public.portfolio;
create policy "public_portfolio_read" on public.portfolio for select to anon, authenticated using(true);
drop policy if exists "admin_portfolio_insert" on public.portfolio;
create policy "admin_portfolio_insert" on public.portfolio for insert to authenticated with check(public.is_studio_admin());
drop policy if exists "admin_portfolio_update" on public.portfolio;
create policy "admin_portfolio_update" on public.portfolio for update to authenticated using(public.is_studio_admin()) with check(public.is_studio_admin());
drop policy if exists "admin_portfolio_delete" on public.portfolio;
create policy "admin_portfolio_delete" on public.portfolio for delete to authenticated using(public.is_studio_admin());
drop policy if exists "public_quote_insert" on public.quotes;
create policy "public_quote_insert" on public.quotes for insert to anon, authenticated with check(
 length(name) between 2 and 120 and length(email) between 5 and 254 and length(message) between 5 and 5000
);
drop policy if exists "admin_quote_read" on public.quotes;
create policy "admin_quote_read" on public.quotes for select to authenticated using(public.is_studio_admin());
-- Tras crear el usuario administrador en Authentication > Users, ejecuta:
-- insert into public.admins(user_id) values ('UUID_DEL_USUARIO');
-- Proteger formulario público con rate limiting/captcha antes de promoverlo.
