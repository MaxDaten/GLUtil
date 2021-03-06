{-# LANGUAGE RankNTypes #-}
-- | Uses the @JuicyPixels@ package to load images that are then used
-- to create OpenGL textuers.
module Graphics.GLUtil.JuicyTextures where
import Codec.Picture (readImage, DynamicImage(..), Image(..))
import Control.Applicative ((<$>))
import Graphics.GLUtil.Textures
import Graphics.Rendering.OpenGL (TextureObject)

-- | Load a 'TexInfo' value from an image file, and supply it to a
-- user-provided function. Supported image formats include @png@,
-- @jpeg@, @bmp@, and @gif@. See 'readTexture' for most uses.
readTexInfo :: FilePath
            -> (forall a. IsPixelData a => TexInfo a -> IO b)
            -> IO (Either String b)
readTexInfo f k = readImage f >>= either (return . Left) aux
  where aux (ImageY8 (Image w h p)) = Right <$> k (texInfo w h TexMono p)
        aux (ImageYF (Image w h p)) = Right <$> k (texInfo w h TexMono p)
        aux (ImageYA8 _) = return $ Left "YA format not supported"
        aux (ImageRGB8 (Image w h p)) = Right <$> k (texInfo w h TexRGB p)
        aux (ImageRGBF (Image w h p)) = Right <$> k (texInfo w h TexRGB p)
        aux (ImageRGBA8 (Image w h p)) = Right <$> k (texInfo w h TexRGBA p)
        aux _ = return $ Left "Unsupported image format"

-- | Load a 'TextureObject' from an image file. Supported formats
-- include @png@, @jpeg@, @bmp@, and @gif@.
readTexture :: FilePath -> IO (Either String TextureObject)
readTexture f = readTexInfo f loadTexture
