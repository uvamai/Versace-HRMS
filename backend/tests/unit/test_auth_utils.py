import pytest

from app.modules.auth.service import create_access_token, decode_access_token, hash_password, verify_password


def test_hash_and_verify_password() -> None:
    raw_password = "SecurePassword123!"
    hashed = hash_password(raw_password)

    assert verify_password(raw_password, hashed)
    assert not verify_password("WrongPassword", hashed)


def test_access_token_encode_decode() -> None:
    token = create_access_token("user-id-123", ["EMPLOYEE"])
    payload = decode_access_token(token)

    assert payload["sub"] == "user-id-123"
    assert payload["roles"] == ["EMPLOYEE"]
    assert payload["type"] == "access"
    assert "exp" in payload
    assert "iat" in payload
