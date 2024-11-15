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
    [AddComponentMenu("Lua/FlowerSpawner")]
    [LuaRegisterType(0x3c4c59969887e0f6, typeof(LuaBehaviour))]
    public class FlowerSpawner : LuaBehaviourThunk
    {
        private const string s_scriptGUID = "a11b0d0f6b7d4fa48ab14a8a565f7b04";
        public override string ScriptGUID => s_scriptGUID;

        [SerializeField] public System.Collections.Generic.List<UnityEngine.GameObject> m_SpawnLocations = default;
        [SerializeField] public System.Collections.Generic.List<UnityEngine.GameObject> m_Flowers = default;

        protected override SerializedPropertyValue[] SerializeProperties()
        {
            if (_script == null)
                return Array.Empty<SerializedPropertyValue>();

            return new SerializedPropertyValue[]
            {
                CreateSerializedProperty(_script.GetPropertyAt(0), m_SpawnLocations),
                CreateSerializedProperty(_script.GetPropertyAt(1), m_Flowers),
            };
        }
    }
}

#endif
