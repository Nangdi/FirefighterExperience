using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace FernandoOleaDev {
    public static class Extensions {

        public static Texture2D DrawCircle(this Texture2D tex, Color color, int x, int y, int radius = 3)
        {
            float rSquared = radius * radius;

            for (int u = x - radius; u < x + radius + 1; u++)
            for (int v = y - radius; v < y + radius + 1; v++)
                if ((x - u) * (x - u) + (y - v) * (y - v) < rSquared)
                    tex.SetPixel(u, v, color);

            return tex;
        }

        public static void PaintAllTexture(this Texture2D tex, Color color) {
            Color[] newColors = new Color[tex.width * tex.height];
            for (int i = 0; i < newColors.Length; i++) {
                newColors[i] = color;
            }
            tex.SetPixels(newColors);
            tex.Apply();
        }
        
        public static void Circle(this Texture2D tex, Color col, int cx, int cy, int r)
        {
            int x, y, px, nx, py, ny, d;
            Color[] tempArray = tex.GetPixels();
 
            for (x = 0; x <= r; x++)
            {
                d = (int)Mathf.Ceil(Mathf.Sqrt(r * r - x * x));
                for (y = 0; y <= d; y++)
                {
                    px = cx + x;
                    nx = cx - x;
                    py = cy + y;
                    ny = cy - y;
 
                    tempArray[Mathf.Clamp(py*tex.width + px,0,tempArray.Length)] = col;
                    tempArray[Mathf.Clamp(py*tex.width + nx,0,tempArray.Length)] = col;
                    tempArray[Mathf.Clamp(ny*tex.width + px,0,tempArray.Length)] = col;
                    tempArray[Mathf.Clamp(ny*tex.width + nx,0,tempArray.Length)] = col;
                }
            }    
            tex.SetPixels(tempArray);
            //tex.Apply ();
        }
    }
    
}