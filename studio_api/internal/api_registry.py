from typing import Type, List, NamedTuple
from studio_api.internal.singleton import ProxiedSingleton
from packaging import version as packaging_version


class StudioAPIBase(ProxiedSingleton):
    def __init__(self):
        pass


class StudioAPIWithVersion(NamedTuple):
    version: str
    api_class: Type[StudioAPIBase]


def parse_version(version_str: str) -> packaging_version.Version:
    """
    Parses a version string into a packaging_version.Version object.
    Raises ValueError if the version string is invalid.
    """
    if version_str == "latest":
        return packaging_version.parse("9999999.9999999.9999999")
    return packaging_version.parse(version_str)


registered_versions: List[StudioAPIWithVersion] = []


def register_versions(versions: List[StudioAPIWithVersion]):
    versions.sort(key=lambda x: parse_version(x.version))
    global registered_versions
    registered_versions = versions


def get_all_versions() -> List[StudioAPIWithVersion]:
    """
    Returns a list of all registered StudioAPI versions.
    """
    return registered_versions
