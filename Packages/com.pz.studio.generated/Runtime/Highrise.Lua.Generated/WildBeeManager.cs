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
    [AddComponentMenu("Lua/WildBeeManager")]
    [LuaRegisterType(0xead08ae944742586, typeof(LuaBehaviour))]
    public class WildBeeManager : LuaBehaviourThunk
    {
        private const string s_scriptGUID = "c8909c5bd53db154087508055992cfe1";
        public override string ScriptGUID => s_scriptGUID;

        [SerializeField] public UnityEngine.GameObject m_CommonBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_StoneBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_ForestBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_AquaticBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_GiantBeePrefab = default;
        [SerializeField] public UnityEngine.GameObject m_SilverBeePrefab = default;

        protected override SerializedPropertyValue[] SerializeProperties()
        {
            if (_script == null)
                return Array.Empty<SerializedPropertyValue>();

            return new SerializedPropertyValue[]
            {
                CreateSerializedProperty(_script.GetPropertyAt(0), m_CommonBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(1), m_StoneBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(2), m_ForestBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(3), m_AquaticBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(4), m_GiantBeePrefab),
                CreateSerializedProperty(_script.GetPropertyAt(5), m_SilverBeePrefab),
            };
        }
    }
}

#endif
