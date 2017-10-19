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
            };

            StructuredBuffer<MeshData> _MeshBuffer;
			StructuredBuffer<ChainData> _ChainDataBuffer;
			

			struct v2f
			{
				float4 vertex : SV_POSITION;
                float tester : TEXCOORD0;
			};


            v2f vert(uint meshId : SV_VertexID, uint instanceId : SV_InstanceID)
            {
                MeshData meshData = _MeshBuffer[meshId];
                ChainData chainData = _ChainDataBuffer[instanceId];

                float3 vertPos = meshData.Position + chainData.Position;

				v2f o;
				o.vertex = UnityObjectToClipPos(float4(vertPos, 1));
                o.tester = meshData.Position.z;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
                return i.tester;
			}
			ENDCG
		}
	}
}
