Shader "Unlit/ChainShader"
{
	Properties
	{
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
            Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
            
			struct MeshData
			{
				float3 Position;
				float3 Normal;
			};

            struct ChainData
            {
                float3 Position;
                float3 LinkNormal;
                float3 LinkBinormal;
            };

            StructuredBuffer<MeshData> _MeshBuffer;
			StructuredBuffer<ChainData> _ChainDataBuffer;
			
            float4x4 _MasterMatrix;

			struct v2f
			{
				float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float indexParam : TEXCOORD1;
			};

            float3 GetMeshPoint(float3 meshPosition, float3 linkNormal, float3 linkBinormal)
            {
                float3 linkTangent = cross(linkNormal, linkBinormal);
                float3 retX = linkBinormal * meshPosition.x;
                float3 retY = linkTangent * meshPosition.y;
                float3 retZ = linkNormal * meshPosition.z;
                return retX + retY + retZ;
            }

            v2f vert(uint meshId : SV_VertexID, uint instanceId : SV_InstanceID)
            {
                ChainData lastChain = _ChainDataBuffer[1023];
                MeshData meshData = _MeshBuffer[meshId];
                ChainData chainData = _ChainDataBuffer[instanceId];
                float3 rotatedMeshPoint = GetMeshPoint(meshData.Position, chainData.LinkNormal, chainData.LinkBinormal);
                float3 rotatedNormal = GetMeshPoint(meshData.Normal, chainData.LinkNormal, chainData.LinkBinormal);
                float3 vertPos = rotatedMeshPoint + chainData.Position - lastChain.Position;
                float4 finalPos = mul(_MasterMatrix, float4(-vertPos, 1));
				v2f o;
				o.vertex = UnityObjectToClipPos(finalPos);
                o.normal = rotatedNormal;
                o.indexParam = (float)instanceId.x / 1000;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
                float shade = dot(float3(0, -1, 0), normalize(i.normal)) / 4 + .75;
                float3 base = lerp(float3(.1, .2, .3) + shade, 0.2, 1 - i.indexParam);
                return float4(base, 1);
			}
			ENDCG
		}
	}
}
