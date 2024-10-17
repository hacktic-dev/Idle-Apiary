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
    [AddComponentMenu("Lua/BeeObjectManager")]
    [LuaRegisterType(0xefb7a8c7c43608c3, typeof(LuaBehaviour))]
    public class BeeObjectManager : LuaBehaviourThunk
    {
        private const string s_scriptGUID = "40664b5e500bbe246afa9423ce9c9910";
        public override string ScriptGUID => s_scriptGUID;

        [SerializeField] public UnityEngine.GameObject m_CommonBee = default;
        [SerializeField] public UnityEngine.GameObject m_StoneBee = default;
        [SerializeField] public UnityEngine.GameObject m_ForestBee = default;
        [SerializeField] public UnityEngine.GameObject m_AquaticBee = default;
        [SerializeField] public UnityEngine.GameObject m_GiantBee = default;
        [SerializeField] public UnityEngine.GameObject m_SilverBee = default;

        protected override SerializedPropertyValue[] SerializeProperties()
        {
            if (_script == null)
                return Array.Empty<SerializedPropertyValue>();

            return new SerializedPropertyValue[]
            {
                CreateSerializedProperty(_script.GetPropertyAt(0), m_CommonBee),
                CreateSerializedProperty(_script.GetPropertyAt(1), m_StoneBee),
                CreateSerializedProperty(_script.GetPropertyAt(2), m_ForestBee),
                CreateSerializedProperty(_script.GetPropertyAt(3), m_AquaticBee),
                CreateSerializedProperty(_script.GetPropertyAt(4), m_GiantBee),
                CreateSerializedProperty(_script.GetPropertyAt(5), m_SilverBee),
            };
        }
    }
}

#endif
