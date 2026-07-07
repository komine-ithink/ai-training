class NotFoundError(Exception):
    def __init__(self, message: str = "employee not found"):
        self.message = message


class ConflictError(Exception):
    def __init__(self, message: str = "employee_id already exists"):
        self.message = message


# Step3(自習パート)で正式なエラーコード・多言語メッセージを定義するまでのプレースホルダー
CODE_VALIDATION = "E001"
CODE_NOT_FOUND = "E002"
CODE_CONFLICT = "E003"
CODE_INTERNAL = "E500"
