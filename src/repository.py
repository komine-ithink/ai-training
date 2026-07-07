from .errors import ConflictError, NotFoundError
from .models import EmployeeCreate, EmployeeResponse, EmployeeUpdate

PAGE_SIZE = 10

_employees: dict[str, EmployeeResponse] = {}


def list_employees(page: int) -> tuple[list[EmployeeResponse], int]:
    ordered = sorted(_employees.values(), key=lambda e: e.employee_id)
    total_count = len(ordered)
    start = (page - 1) * PAGE_SIZE
    return ordered[start : start + PAGE_SIZE], total_count


def create_employee(data: EmployeeCreate) -> EmployeeResponse:
    if data.employee_id in _employees:
        raise ConflictError()
    employee = EmployeeResponse(**data.model_dump())
    _employees[employee.employee_id] = employee
    return employee


def update_employee(employee_id: str, data: EmployeeUpdate) -> EmployeeResponse:
    if employee_id not in _employees:
        raise NotFoundError()
    employee = EmployeeResponse(employee_id=employee_id, **data.model_dump())
    _employees[employee_id] = employee
    return employee


def delete_employee(employee_id: str) -> None:
    if employee_id not in _employees:
        raise NotFoundError()
    del _employees[employee_id]
