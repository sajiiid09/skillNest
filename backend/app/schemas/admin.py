from pydantic import BaseModel


class AdminDashboardRead(BaseModel):
    total_buyers: int
    total_developers: int
    total_projects: int
    total_tasks: int
    tasks_todo: int
    tasks_in_progress: int
    tasks_submitted: int
    tasks_completed: int
    total_revenue: float
