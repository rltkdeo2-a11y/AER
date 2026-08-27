PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS sources (
    source_id TEXT PRIMARY KEY,
    relative_path TEXT NOT NULL UNIQUE,
    document_id TEXT,
    project_id TEXT NOT NULL,
    context TEXT NOT NULL,
    use_scope TEXT NOT NULL,
    document_time TEXT,
    effective_time TEXT,
    content_hash TEXT NOT NULL,
    content_version INTEGER NOT NULL DEFAULT 1,
    state TEXT NOT NULL DEFAULT 'ACTIVE'
        CHECK (state IN ('ACTIVE', 'CHANGED', 'MISSING')),
    metadata_json TEXT NOT NULL,
    ingested_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS statements (
    statement_id TEXT PRIMARY KEY,
    source_id TEXT NOT NULL REFERENCES sources(source_id),
    project_id TEXT NOT NULL,
    context TEXT NOT NULL,
    use_scope TEXT NOT NULL,
    line_start INTEGER NOT NULL,
    line_end INTEGER NOT NULL,
    statement_type TEXT NOT NULL
        CHECK (statement_type IN ('FACT', 'DISCUSSION', 'DECISION', 'APPROVAL', 'EFFECTIVE')),
    content TEXT NOT NULL,
    event_time TEXT,
    effective_time TEXT,
    disposition TEXT NOT NULL DEFAULT 'CURRENT'
        CHECK (disposition IN ('CURRENT', 'SUPERSEDED', 'DISPUTED', 'UNCERTAIN')),
    uncertainty TEXT,
    review_state TEXT NOT NULL DEFAULT 'AUTO'
        CHECK (review_state IN ('AUTO', 'REVIEWED', 'REVIEW_REQUIRED')),
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS relations (
    relation_id TEXT PRIMARY KEY,
    from_kind TEXT NOT NULL CHECK (from_kind IN ('SOURCE', 'STATEMENT')),
    from_id TEXT NOT NULL,
    to_kind TEXT NOT NULL CHECK (to_kind IN ('SOURCE', 'STATEMENT')),
    to_id TEXT NOT NULL,
    relation_type TEXT NOT NULL
        CHECK (relation_type IN (
            'EVIDENCED_BY', 'PRECEDES', 'SUPERSEDES', 'CONFLICTS_WITH',
            'APPROVES', 'MAKES_EFFECTIVE', 'DEPENDS_ON', 'IMPACTS'
        )),
    evidence_source_id TEXT REFERENCES sources(source_id),
    status TEXT NOT NULL DEFAULT 'ACTIVE'
        CHECK (status IN ('ACTIVE', 'SUPERSEDED')),
    created_by TEXT NOT NULL CHECK (created_by IN ('AUTO', 'HUMAN')),
    created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS revisions (
    revision_id INTEGER PRIMARY KEY AUTOINCREMENT,
    target_kind TEXT NOT NULL CHECK (target_kind IN ('SOURCE', 'STATEMENT', 'RELATION')),
    target_id TEXT NOT NULL,
    field_name TEXT NOT NULL,
    before_value TEXT,
    after_value TEXT,
    reason TEXT NOT NULL,
    reviewer TEXT NOT NULL,
    revised_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS operations (
    operation_id INTEGER PRIMARY KEY AUTOINCREMENT,
    run_id TEXT,
    task_id TEXT,
    condition_name TEXT,
    phase TEXT,
    operation_type TEXT NOT NULL,
    started_at TEXT NOT NULL,
    ended_at TEXT NOT NULL,
    human_seconds REAL NOT NULL DEFAULT 0 CHECK (human_seconds >= 0),
    human_action TEXT,
    affected_sources INTEGER NOT NULL DEFAULT 0,
    affected_statements INTEGER NOT NULL DEFAULT 0,
    details_json TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_sources_project ON sources(project_id, context);
CREATE INDEX IF NOT EXISTS idx_statements_source ON statements(source_id);
CREATE INDEX IF NOT EXISTS idx_statements_project_time ON statements(project_id, event_time, effective_time);
CREATE INDEX IF NOT EXISTS idx_statements_review ON statements(review_state, disposition);
CREATE INDEX IF NOT EXISTS idx_relations_from ON relations(from_kind, from_id, relation_type);
CREATE INDEX IF NOT EXISTS idx_relations_to ON relations(to_kind, to_id, relation_type);
CREATE INDEX IF NOT EXISTS idx_operations_run ON operations(run_id, task_id, condition_name, phase);
