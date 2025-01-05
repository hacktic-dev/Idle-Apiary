/*

    Copyright (c) 2025 Pocketz World. All rights reserved.

    This is a generated file, do not edit!

    Generated by com.pz.studio
*/

#if UNITY_EDITOR

using System;
using System.Linq;
using UnityEngine;
using Highrise.Client;
using Highrise.Studio;
using Highrise.Lua;

namespace Highrise.Lua.Generated
{
    [AddComponentMenu("Lua/ApiaryManager")]
    [LuaRegisterType(0x29d42c5a2ed2bd9a, typeof(LuaBehaviour))]
    public class ApiaryManager : LuaBehaviourThunk
    {
        private const string s_scriptGUID = "53204b58522b6744ba7f19b17377614b";
        public override string ScriptGUID => s_scriptGUID;

        [SerializeField] public UnityEngine.GameObject m_ApiaryPrefab = default;

        protected override SerializedPropertyValue[] SerializeProperties()
        {
            if (_script == null)
                return Array.Empty<SerializedPropertyValue>();

            return new SerializedPropertyValue[]
            {
                CreateSerializedProperty(_script.GetPropertyAt(0), m_ApiaryPrefab),
            };
        }
    }
}

#endif
