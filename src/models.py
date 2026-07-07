from pydantic import BaseModel, ConfigDict, Field


class EmployeeCreate(BaseModel):
    employee_id: str = Field(min_length=1)
    name: str = Field(min_length=1)
    department: str = Field(min_length=1)
    position: str = Field(min_length=1)


class EmployeeUpdate(BaseModel):
    model_config = ConfigDict(extra="forbid")

    name: str = Field(min_length=1)
    department: str = Field(min_length=1)
    position: str = Field(min_length=1)


class EmployeeResponse(BaseModel):
    employee_id: str
    name: str
    department: str
    position: str


class EmployeeListResponse(BaseModel):
    total_count: int
    page: int
    items: list[EmployeeResponse]


class ErrorDetail(BaseModel):
    field: str
    reason: str


class ErrorBody(BaseModel):
    code: str
    message: str
    details: list[ErrorDetail] | None = None


class ErrorResponse(BaseModel):
    error: ErrorBody
