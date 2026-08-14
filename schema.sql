-- ═══════════════════════════════════════════════════════════════
-- «مدرستي» — مخطط Supabase (الخطة المجانية)
-- نفّذه كما هو في: SQL Editor ← New query ← Run
-- ═══════════════════════════════════════════════════════════════

create table if not exists public.nb_schools (
  id         text primary key,
  tenant     text not null,
  name       text not null,
  manager    text default '',
  plan       text default 'full',
  start_date text,
  end_date   text,
  paid       bigint default 0,
  acc_user   text,
  acc_hash   text,
  acc_salt   text,
  email      text,
  phone      text,
  rep        jsonb default '[]',
  updated_at timestamptz not null default now()
);

create table if not exists public.nb_school_data (
  school_id  text primary key references public.nb_schools(id) on delete cascade,
  tenant     text not null,
  db         jsonb,
  tt         text,
  updated_at timestamptz not null default now()
);

create table if not exists public.nb_inbox (
  id          text primary key,
  tenant      text not null,
  school_id   text,
  school_name text,
  title       text,
  body        text,
  status      text default 'new',
  created_at  timestamptz not null default now()
);

alter table public.nb_schools     enable row level security;
alter table public.nb_school_data enable row level security;
alter table public.nb_inbox       enable row level security;

-- سياسات الوصول: معرف المزامنة (tenant) سرّ يُنشأ على جهازك ويُدخل في التطبيق.
-- ملاحظة أمان: السياسات مفتوحة لدور anon لبساطة الخطة المجانية؛
-- عند الترقية الإنتاجية استبدلها بـ Supabase Auth (توثيق البريد) وسياسات لكل مستخدم.
create policy "nb_schools_access" on public.nb_schools
  for all to anon using (true) with check (true);
create policy "nb_data_access" on public.nb_school_data
  for all to anon using (true) with check (true);
create policy "nb_inbox_access" on public.nb_inbox
  for all to anon using (true) with check (true);

-- فهارس لتسريع الاستعلام حسب المعرف
create index if not exists idx_nb_schools_tenant on public.nb_schools(tenant);
create index if not exists idx_nb_data_tenant   on public.nb_school_data(tenant);
create index if not exists idx_nb_inbox_tenant  on public.nb_inbox(tenant);
