﻿using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MainScript : MonoBehaviour 
{
    public Material ChainMat;
    public ComputeShader ChainCompute;
    public Mesh ChainMesh;

    public int ChainLinkCount;

    struct MeshData
    {
        public Vector3 Position;
        public Vector3 Normal;
    }

    struct ChainData
    {
        public Vector3 Position;
        public Vector3 LinkNormal;
    }

    private ComputeBuffer meshBuffer;
    private ComputeBuffer chainDataBuffer;
    private int chainComputeKernel;
    private const int computeThreadCount = 128;
    private int groupsToDispatch;

    private const int MeshBufferStride = sizeof(float) * 3 + sizeof(float) * 3;
    private const int ChainDataBufferStride = sizeof(float) * 3 + sizeof(float) * 3;

    private void Start()
    {
        meshBuffer = GetMeshBuffer();
        chainDataBuffer = GetChainDataBuffer();
        chainComputeKernel = ChainCompute.FindKernel("ChainCompute");
        groupsToDispatch = Mathf.CeilToInt((float)ChainLinkCount / computeThreadCount);
    }

    private void Update()
    {
        ChainCompute.SetBuffer(chainComputeKernel, "_ChainDataBuffer", chainDataBuffer);
        ChainCompute.Dispatch(chainComputeKernel, groupsToDispatch, 1, 1);

        ChainMat.SetBuffer("_MeshBuffer", meshBuffer);
        ChainMat.SetBuffer("_ChainDataBuffer", chainDataBuffer);
    }

    private ComputeBuffer GetMeshBuffer()
    {
        int meshBufferCount = ChainMesh.triangles.Length;
        ComputeBuffer ret = new ComputeBuffer(meshBufferCount, MeshBufferStride);

        MeshData[] meshVerts = new MeshData[meshBufferCount];
        for (int i = 0; i < meshBufferCount; i++)
        {
            meshVerts[i].Position = ChainMesh.vertices[ChainMesh.triangles[i]];
            meshVerts[i].Normal = ChainMesh.normals[ChainMesh.triangles[i]];
        }
        ret.SetData(meshVerts);
        return ret;
    }

    private ComputeBuffer GetChainDataBuffer()
    {
        ComputeBuffer ret = new ComputeBuffer(ChainLinkCount, ChainDataBufferStride);
        ChainData[] data = new ChainData[ChainLinkCount];
        for (int i = 0; i < ChainLinkCount; i++)
        {
            ChainData datum = new ChainData();
            datum.Position = new Vector3(0, 0, i);
            data[i] = datum;
        }
        ret.SetData(data);
        return ret;
    }
    void OnRenderObject()
    {
        ChainMat.SetPass(0);
        Graphics.DrawProcedural(MeshTopology.Triangles, ChainMesh.triangles.Length, ChainLinkCount);
    }
}
