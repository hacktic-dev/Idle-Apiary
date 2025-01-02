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
    [AddComponentMenu("Lua/WingRotator")]
    [LuaRegisterType(0x745f8dea7e5a913b, typeof(LuaBehaviour))]
    public class WingRotator : LuaBehaviourThunk
    {
        private const string s_scriptGUID = "b7044b5e8f1029942a724b4c7f7e7900";
        public override string ScriptGUID => s_scriptGUID;

        [SerializeField] public System.Double m_direction = 1;
        [SerializeField] public UnityEngine.GameObject m_mainCam = default;

        protected override SerializedPropertyValue[] SerializeProperties()
        {
            if (_script == null)
                return Array.Empty<SerializedPropertyValue>();

            return new SerializedPropertyValue[]
            {
                CreateSerializedProperty(_script.GetPropertyAt(0), m_direction),
                CreateSerializedProperty(_script.GetPropertyAt(1), m_mainCam),
            };
        }
    }
}

#endif
