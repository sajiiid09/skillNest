"""Initial schema."""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


revision = "20260313_0001"
down_revision = None
branch_labels = None
depends_on = None


user_role = sa.Enum("buyer", "developer", "admin", name="user_role", native_enum=False)
proposal_status = sa.Enum(
    "pending",
    "accepted",
    "rejected",
    name="proposal_status",
    native_enum=False,
)
task_status = sa.Enum(
    "in_progress",
    "submitted",
    "paid",
    name="task_status",
    native_enum=False,
)
payment_provider = sa.Enum("stripe_test", name="payment_provider", native_enum=False)
payment_status = sa.Enum("paid", name="payment_status", native_enum=False)


def upgrade() -> None:
    bind = op.get_bind()
    user_role.create(bind, checkfirst=True)
    proposal_status.create(bind, checkfirst=True)
    task_status.create(bind, checkfirst=True)
    payment_provider.create(bind, checkfirst=True)
    payment_status.create(bind, checkfirst=True)

    op.create_table(
        "users",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("email", sa.String(length=255), nullable=False),
        sa.Column("full_name", sa.String(length=255), nullable=False),
        sa.Column("password_hash", sa.String(length=255), nullable=False),
        sa.Column("role", user_role, nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )
    op.create_index("ix_users_email", "users", ["email"], unique=True)
    op.create_index("ix_users_id", "users", ["id"], unique=False)

    op.create_table(
        "projects",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("buyer_id", sa.Integer(), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("title", sa.String(length=255), nullable=False),
        sa.Column("description", sa.Text(), nullable=False),
        sa.Column("expected_hourly_rate", sa.Numeric(10, 2), nullable=False),
        sa.Column("expected_duration_hours", sa.Numeric(10, 2), nullable=False),
        sa.Column("tags", postgresql.ARRAY(sa.String()), nullable=False),
        sa.Column("is_open", sa.Boolean(), server_default=sa.text("true"), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )
    op.create_index("ix_projects_buyer_id", "projects", ["buyer_id"], unique=False)
    op.create_index("ix_projects_id", "projects", ["id"], unique=False)

    op.create_table(
        "proposals",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("project_id", sa.Integer(), sa.ForeignKey("projects.id"), nullable=False),
        sa.Column("developer_id", sa.Integer(), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("cover_letter", sa.Text(), nullable=False),
        sa.Column("proposed_hourly_rate", sa.Numeric(10, 2), nullable=False),
        sa.Column("estimated_hours", sa.Numeric(10, 2), nullable=False),
        sa.Column("status", proposal_status, server_default="pending", nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )
    op.create_index("ix_proposals_developer_id", "proposals", ["developer_id"], unique=False)
    op.create_index("ix_proposals_id", "proposals", ["id"], unique=False)
    op.create_index("ix_proposals_project_id", "proposals", ["project_id"], unique=False)

    op.create_table(
        "tasks",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("project_id", sa.Integer(), sa.ForeignKey("projects.id"), nullable=False),
        sa.Column("developer_id", sa.Integer(), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("buyer_id", sa.Integer(), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("title", sa.String(length=255), nullable=False),
        sa.Column("description", sa.Text(), nullable=False),
        sa.Column("hourly_rate", sa.Numeric(10, 2), nullable=False),
        sa.Column("estimated_hours", sa.Numeric(10, 2), nullable=False),
        sa.Column("time_spent", sa.Numeric(10, 2), server_default="0", nullable=False),
        sa.Column("status", task_status, server_default="in_progress", nullable=False),
        sa.Column("solution_file_path", sa.String(length=500), nullable=True),
        sa.Column("submitted_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )
    op.create_index("ix_tasks_buyer_id", "tasks", ["buyer_id"], unique=False)
    op.create_index("ix_tasks_developer_id", "tasks", ["developer_id"], unique=False)
    op.create_index("ix_tasks_id", "tasks", ["id"], unique=False)
    op.create_index("ix_tasks_project_id", "tasks", ["project_id"], unique=False)

    op.create_table(
        "payments",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("task_id", sa.Integer(), sa.ForeignKey("tasks.id"), nullable=False),
        sa.Column("buyer_id", sa.Integer(), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("developer_id", sa.Integer(), sa.ForeignKey("users.id"), nullable=False),
        sa.Column("amount", sa.Numeric(10, 2), nullable=False),
        sa.Column("currency", sa.String(length=10), nullable=False),
        sa.Column("provider", payment_provider, server_default="stripe_test", nullable=False),
        sa.Column("provider_payment_id", sa.String(length=255), nullable=False),
        sa.Column("status", payment_status, server_default="paid", nullable=False),
        sa.Column("paid_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.UniqueConstraint("task_id"),
    )
    op.create_index("ix_payments_buyer_id", "payments", ["buyer_id"], unique=False)
    op.create_index("ix_payments_developer_id", "payments", ["developer_id"], unique=False)
    op.create_index("ix_payments_id", "payments", ["id"], unique=False)
    op.create_index("ix_payments_task_id", "payments", ["task_id"], unique=False)


def downgrade() -> None:
    op.drop_index("ix_payments_task_id", table_name="payments")
    op.drop_index("ix_payments_id", table_name="payments")
    op.drop_index("ix_payments_developer_id", table_name="payments")
    op.drop_index("ix_payments_buyer_id", table_name="payments")
    op.drop_table("payments")

    op.drop_index("ix_tasks_project_id", table_name="tasks")
    op.drop_index("ix_tasks_id", table_name="tasks")
    op.drop_index("ix_tasks_developer_id", table_name="tasks")
    op.drop_index("ix_tasks_buyer_id", table_name="tasks")
    op.drop_table("tasks")

    op.drop_index("ix_proposals_project_id", table_name="proposals")
    op.drop_index("ix_proposals_id", table_name="proposals")
    op.drop_index("ix_proposals_developer_id", table_name="proposals")
    op.drop_table("proposals")

    op.drop_index("ix_projects_id", table_name="projects")
    op.drop_index("ix_projects_buyer_id", table_name="projects")
    op.drop_table("projects")

    op.drop_index("ix_users_id", table_name="users")
    op.drop_index("ix_users_email", table_name="users")
    op.drop_table("users")

    bind = op.get_bind()
    payment_status.drop(bind, checkfirst=True)
    payment_provider.drop(bind, checkfirst=True)
    task_status.drop(bind, checkfirst=True)
    proposal_status.drop(bind, checkfirst=True)
    user_role.drop(bind, checkfirst=True)
