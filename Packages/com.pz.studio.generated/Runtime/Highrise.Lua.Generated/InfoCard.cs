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
    [AddComponentMenu("Lua/InfoCard")]
    [LuaRegisterType(0x864b60939a9270ff, typeof(LuaBehaviour))]
    public class InfoCard : LuaBehaviourThunk
    {
        private const string s_scriptGUID = "106c10ae9059f7b44877d5997e1b20d2";
        public override string ScriptGUID => s_scriptGUID;


        protected override SerializedPropertyValue[] SerializeProperties()
        {
            if (_script == null)
                return Array.Empty<SerializedPropertyValue>();

            return new SerializedPropertyValue[]
            {
                CreateSerializedProperty(_script.GetPropertyAt(0), null),
                CreateSerializedProperty(_script.GetPropertyAt(1), null),
                CreateSerializedProperty(_script.GetPropertyAt(2), null),
                CreateSerializedProperty(_script.GetPropertyAt(3), null),
                CreateSerializedProperty(_script.GetPropertyAt(4), null),
                CreateSerializedProperty(_script.GetPropertyAt(5), null),
                CreateSerializedProperty(_script.GetPropertyAt(6), null),
            };
        }
    }
}

#endif
