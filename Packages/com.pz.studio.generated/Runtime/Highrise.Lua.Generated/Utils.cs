/*

    Copyright (c) 2024 Pocketz World. All rights reserved.

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
    [AddComponentMenu("Lua/Utils")]
    [LuaRegisterType(0xf5b4b7dd8516094e, typeof(LuaBehaviour))]
    public class Utils : LuaBehaviourThunk
    {
        private const string s_scriptGUID = "41f98c9280c0afb42ad3c06972d4f34a";
        public override string ScriptGUID => s_scriptGUID;

        [SerializeField] public System.Collections.Generic.List<UnityEngine.Texture> m_beeTextures = default;
        [SerializeField] public System.Collections.Generic.List<UnityEngine.Texture> m_hatTextures = default;
        [SerializeField] public System.Collections.Generic.List<UnityEngine.GameObject> m_placementObjects = default;

        protected override SerializedPropertyValue[] SerializeProperties()
        {
            if (_script == null)
                return Array.Empty<SerializedPropertyValue>();

            return new SerializedPropertyValue[]
            {
                CreateSerializedProperty(_script.GetPropertyAt(0), m_beeTextures),
                CreateSerializedProperty(_script.GetPropertyAt(1), m_hatTextures),
                CreateSerializedProperty(_script.GetPropertyAt(2), m_placementObjects),
            };
        }
    }
}

#endif
