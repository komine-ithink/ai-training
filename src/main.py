from fastapi import FastAPI, Query, Request, Response
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse

from .errors import CODE_CONFLICT, CODE_NOT_FOUND, CODE_VALIDATION, ConflictError, NotFoundError
from .models import EmployeeCreate, EmployeeListResponse, EmployeeResponse, EmployeeUpdate
from . import repository

app = FastAPI(title="社員管理システム API")


def _error_body(code: str, message: str, details: list[dict] | None = None) -> dict:
    body = {"error": {"code": code, "message": message}}
    if details:
        body["error"]["details"] = details
    return body


@app.exception_handler(RequestValidationError)
async def validation_error_handler(request: Request, exc: RequestValidationError):
    details = [
        {"field": ".".join(str(p) for p in e["loc"] if p != "body"), "reason": e["msg"]}
        for e in exc.errors()
    ]
    return JSONResponse(
        status_code=400,
        content=_error_body(CODE_VALIDATION, "invalid request", details),
    )


@app.exception_handler(NotFoundError)
async def not_found_handler(request: Request, exc: NotFoundError):
    return JSONResponse(status_code=404, content=_error_body(CODE_NOT_FOUND, exc.message))


@app.exception_handler(ConflictError)
async def conflict_handler(request: Request, exc: ConflictError):
    return JSONResponse(status_code=409, content=_error_body(CODE_CONFLICT, exc.message))


@app.get("/employees", response_model=EmployeeListResponse)
def get_employees(page: int = Query(default=1, ge=1)):
    items, total_count = repository.list_employees(page)
    return EmployeeListResponse(total_count=total_count, page=page, items=items)


@app.post("/employees", response_model=EmployeeResponse, status_code=201)
def post_employee(data: EmployeeCreate):
    return repository.create_employee(data)


@app.put("/employees/{employee_id}", response_model=EmployeeResponse)
def put_employee(employee_id: str, data: EmployeeUpdate):
    return repository.update_employee(employee_id, data)


@app.delete("/employees/{employee_id}", status_code=204)
def delete_employee(employee_id: str):
    repository.delete_employee(employee_id)
    return Response(status_code=204)
