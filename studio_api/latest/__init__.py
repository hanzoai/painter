from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Type, TYPE_CHECKING
from studio_api.internal import StudioAPIBase
from studio_api.internal.singleton import ProxiedSingleton
from studio_api.internal.async_to_sync import create_sync_class
from studio_api.latest._input import ImageInput, AudioInput, MaskInput, LatentInput, VideoInput
from studio_api.latest._input_impl import VideoFromFile, VideoFromComponents
from studio_api.latest._util import VideoCodec, VideoContainer, VideoComponents, MESH, VOXEL
from . import _io as io
from . import _ui as ui
# from studio_api.latest._resources import _RESOURCES as resources  #noqa: F401
from studio_execution.utils import get_executing_context
from studio_execution.progress import get_progress_state, PreviewImageTuple
from PIL import Image
from studio.cli_args import args
import numpy as np


class StudioAPI_latest(StudioAPIBase):
    VERSION = "latest"
    STABLE = False

    class Execution(ProxiedSingleton):
        async def set_progress(
            self,
            value: float,
            max_value: float,
            node_id: str | None = None,
            preview_image: Image.Image | ImageInput | None = None,
            ignore_size_limit: bool = False,
        ) -> None:
            """
            Update the progress bar displayed in the Studio interface.

            This function allows custom nodes and API calls to report their progress
            back to the user interface, providing visual feedback during long operations.

            Migration from previous API: studio.utils.PROGRESS_BAR_HOOK
            """
            executing_context = get_executing_context()
            if node_id is None and executing_context is not None:
                node_id = executing_context.node_id
            if node_id is None:
                raise ValueError("node_id must be provided if not in executing context")

            # Convert preview_image to PreviewImageTuple if needed
            to_display: PreviewImageTuple | Image.Image | ImageInput | None = preview_image
            if to_display is not None:
                # First convert to PIL Image if needed
                if isinstance(to_display, ImageInput):
                    # Convert ImageInput (torch.Tensor) to PIL Image
                    # Handle tensor shape [B, H, W, C] -> get first image if batch
                    tensor = to_display
                    if len(tensor.shape) == 4:
                        tensor = tensor[0]

                    # Convert to numpy array and scale to 0-255
                    image_np = (tensor.cpu().numpy() * 255).astype(np.uint8)
                    to_display = Image.fromarray(image_np)

                if isinstance(to_display, Image.Image):
                    # Detect image format from PIL Image
                    image_format = to_display.format if to_display.format else "JPEG"
                    # Use None for preview_size if ignore_size_limit is True
                    preview_size = None if ignore_size_limit else args.preview_size
                    to_display = (image_format, to_display, preview_size)

            get_progress_state().update_progress(
                node_id=node_id,
                value=value,
                max_value=max_value,
                image=to_display,
            )

    execution: Execution

class StudioExtension(ABC):
    async def on_load(self) -> None:
        """
        Called when an extension is loaded.
        This should be used to initialize any global resources neeeded by the extension.
        """

    @abstractmethod
    async def get_node_list(self) -> list[type[io.StudioNode]]:
        """
        Returns a list of nodes that this extension provides.
        """

class Input:
    Image = ImageInput
    Audio = AudioInput
    Mask = MaskInput
    Latent = LatentInput
    Video = VideoInput

class InputImpl:
    VideoFromFile = VideoFromFile
    VideoFromComponents = VideoFromComponents

class Types:
    VideoCodec = VideoCodec
    VideoContainer = VideoContainer
    VideoComponents = VideoComponents
    MESH = MESH
    VOXEL = VOXEL

StudioAPI = StudioAPI_latest

# Create a synchronous version of the API
if TYPE_CHECKING:
    import studio_api.latest.generated.StudioAPISyncStub  # type: ignore

    StudioAPISync: Type[studio_api.latest.generated.StudioAPISyncStub.StudioAPISyncStub]
StudioAPISync = create_sync_class(StudioAPI_latest)

# create new aliases for io and ui
IO = io
UI = ui

__all__ = [
    "StudioAPI",
    "StudioAPISync",
    "Input",
    "InputImpl",
    "Types",
    "StudioExtension",
    "io",
    "IO",
    "ui",
    "UI",
]
