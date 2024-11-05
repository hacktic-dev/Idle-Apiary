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
    [AddComponentMenu("Lua/ApiaryPrefabOwner")]
    [LuaRegisterType(0x6071ee1f5b740c64, typeof(LuaBehaviour))]
    public class ApiaryPrefabOwner : LuaBehaviourThunk
    {
        private const string s_scriptGUID = "ed04c801dc299ec4e8fb2c21f46e5a4b";
        public override string ScriptGUID => s_scriptGUID;

        [SerializeField] public UnityEngine.GameObject m_RegularBox = default;
        [SerializeField] public UnityEngine.GameObject m_GoldBox = default;

        protected override SerializedPropertyValue[] SerializeProperties()
        {
            if (_script == null)
                return Array.Empty<SerializedPropertyValue>();

            return new SerializedPropertyValue[]
            {
                CreateSerializedProperty(_script.GetPropertyAt(0), m_RegularBox),
                CreateSerializedProperty(_script.GetPropertyAt(1), m_GoldBox),
            };
        }
    }
}

#endif
