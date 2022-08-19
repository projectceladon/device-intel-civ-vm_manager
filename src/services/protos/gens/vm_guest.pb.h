// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: vm_guest.proto

#ifndef GOOGLE_PROTOBUF_INCLUDED_vm_5fguest_2eproto
#define GOOGLE_PROTOBUF_INCLUDED_vm_5fguest_2eproto

#include <limits>
#include <string>

#include <google/protobuf/port_def.inc>
#if PROTOBUF_VERSION < 3019000
#error This file was generated by a newer version of protoc which is
#error incompatible with your Protocol Buffer headers. Please update
#error your headers.
#endif
#if 3019004 < PROTOBUF_MIN_PROTOC_VERSION
#error This file was generated by an older version of protoc which is
#error incompatible with your Protocol Buffer headers. Please
#error regenerate this file with a newer version of protoc.
#endif

#include <google/protobuf/port_undef.inc>
#include <google/protobuf/io/coded_stream.h>
#include <google/protobuf/arena.h>
#include <google/protobuf/arenastring.h>
#include <google/protobuf/generated_message_table_driven.h>
#include <google/protobuf/generated_message_util.h>
#include <google/protobuf/metadata_lite.h>
#include <google/protobuf/generated_message_reflection.h>
#include <google/protobuf/message.h>
#include <google/protobuf/repeated_field.h>  // IWYU pragma: export
#include <google/protobuf/extension_set.h>  // IWYU pragma: export
#include <google/protobuf/generated_enum_reflection.h>
#include <google/protobuf/unknown_field_set.h>
#include "common.pb.h"
// @@protoc_insertion_point(includes)
#include <google/protobuf/port_def.inc>
#define PROTOBUF_INTERNAL_EXPORT_vm_5fguest_2eproto
PROTOBUF_NAMESPACE_OPEN
namespace internal {
class AnyMetadata;
}  // namespace internal
PROTOBUF_NAMESPACE_CLOSE

// Internal implementation detail -- do not use these members.
struct TableStruct_vm_5fguest_2eproto {
  static const ::PROTOBUF_NAMESPACE_ID::internal::ParseTableField entries[]
    PROTOBUF_SECTION_VARIABLE(protodesc_cold);
  static const ::PROTOBUF_NAMESPACE_ID::internal::AuxiliaryParseTableField aux[]
    PROTOBUF_SECTION_VARIABLE(protodesc_cold);
  static const ::PROTOBUF_NAMESPACE_ID::internal::ParseTable schema[2]
    PROTOBUF_SECTION_VARIABLE(protodesc_cold);
  static const ::PROTOBUF_NAMESPACE_ID::internal::FieldMetadata field_metadata[];
  static const ::PROTOBUF_NAMESPACE_ID::internal::SerializationTable serialization_table[];
  static const uint32_t offsets[];
};
extern const ::PROTOBUF_NAMESPACE_ID::internal::DescriptorTable descriptor_table_vm_5fguest_2eproto;
namespace vm_manager {
class AppLaunchRequest;
struct AppLaunchRequestDefaultTypeInternal;
extern AppLaunchRequestDefaultTypeInternal _AppLaunchRequest_default_instance_;
class AppLaunchResponse;
struct AppLaunchResponseDefaultTypeInternal;
extern AppLaunchResponseDefaultTypeInternal _AppLaunchResponse_default_instance_;
}  // namespace vm_manager
PROTOBUF_NAMESPACE_OPEN
template<> ::vm_manager::AppLaunchRequest* Arena::CreateMaybeMessage<::vm_manager::AppLaunchRequest>(Arena*);
template<> ::vm_manager::AppLaunchResponse* Arena::CreateMaybeMessage<::vm_manager::AppLaunchResponse>(Arena*);
PROTOBUF_NAMESPACE_CLOSE
namespace vm_manager {

enum AppStatus : int {
  UNKNOWN = 0,
  LAUNCHED = 1,
  EXITED = 2,
  FAILED = 3,
  AppStatus_INT_MIN_SENTINEL_DO_NOT_USE_ = std::numeric_limits<int32_t>::min(),
  AppStatus_INT_MAX_SENTINEL_DO_NOT_USE_ = std::numeric_limits<int32_t>::max()
};
bool AppStatus_IsValid(int value);
constexpr AppStatus AppStatus_MIN = UNKNOWN;
constexpr AppStatus AppStatus_MAX = FAILED;
constexpr int AppStatus_ARRAYSIZE = AppStatus_MAX + 1;

const ::PROTOBUF_NAMESPACE_ID::EnumDescriptor* AppStatus_descriptor();
template<typename T>
inline const std::string& AppStatus_Name(T enum_t_value) {
  static_assert(::std::is_same<T, AppStatus>::value ||
    ::std::is_integral<T>::value,
    "Incorrect type passed to function AppStatus_Name.");
  return ::PROTOBUF_NAMESPACE_ID::internal::NameOfEnum(
    AppStatus_descriptor(), enum_t_value);
}
inline bool AppStatus_Parse(
    ::PROTOBUF_NAMESPACE_ID::ConstStringParam name, AppStatus* value) {
  return ::PROTOBUF_NAMESPACE_ID::internal::ParseNamedEnum<AppStatus>(
    AppStatus_descriptor(), name, value);
}
// ===================================================================

class AppLaunchRequest final :
    public ::PROTOBUF_NAMESPACE_ID::Message /* @@protoc_insertion_point(class_definition:vm_manager.AppLaunchRequest) */ {
 public:
  inline AppLaunchRequest() : AppLaunchRequest(nullptr) {}
  ~AppLaunchRequest() override;
  explicit constexpr AppLaunchRequest(::PROTOBUF_NAMESPACE_ID::internal::ConstantInitialized);

  AppLaunchRequest(const AppLaunchRequest& from);
  AppLaunchRequest(AppLaunchRequest&& from) noexcept
    : AppLaunchRequest() {
    *this = ::std::move(from);
  }

  inline AppLaunchRequest& operator=(const AppLaunchRequest& from) {
    CopyFrom(from);
    return *this;
  }
  inline AppLaunchRequest& operator=(AppLaunchRequest&& from) noexcept {
    if (this == &from) return *this;
    if (GetOwningArena() == from.GetOwningArena()
  #ifdef PROTOBUF_FORCE_COPY_IN_MOVE
        && GetOwningArena() != nullptr
  #endif  // !PROTOBUF_FORCE_COPY_IN_MOVE
    ) {
      InternalSwap(&from);
    } else {
      CopyFrom(from);
    }
    return *this;
  }

  static const ::PROTOBUF_NAMESPACE_ID::Descriptor* descriptor() {
    return GetDescriptor();
  }
  static const ::PROTOBUF_NAMESPACE_ID::Descriptor* GetDescriptor() {
    return default_instance().GetMetadata().descriptor;
  }
  static const ::PROTOBUF_NAMESPACE_ID::Reflection* GetReflection() {
    return default_instance().GetMetadata().reflection;
  }
  static const AppLaunchRequest& default_instance() {
    return *internal_default_instance();
  }
  static inline const AppLaunchRequest* internal_default_instance() {
    return reinterpret_cast<const AppLaunchRequest*>(
               &_AppLaunchRequest_default_instance_);
  }
  static constexpr int kIndexInFileMessages =
    0;

  friend void swap(AppLaunchRequest& a, AppLaunchRequest& b) {
    a.Swap(&b);
  }
  inline void Swap(AppLaunchRequest* other) {
    if (other == this) return;
  #ifdef PROTOBUF_FORCE_COPY_IN_SWAP
    if (GetOwningArena() != nullptr &&
        GetOwningArena() == other->GetOwningArena()) {
   #else  // PROTOBUF_FORCE_COPY_IN_SWAP
    if (GetOwningArena() == other->GetOwningArena()) {
  #endif  // !PROTOBUF_FORCE_COPY_IN_SWAP
      InternalSwap(other);
    } else {
      ::PROTOBUF_NAMESPACE_ID::internal::GenericSwap(this, other);
    }
  }
  void UnsafeArenaSwap(AppLaunchRequest* other) {
    if (other == this) return;
    GOOGLE_DCHECK(GetOwningArena() == other->GetOwningArena());
    InternalSwap(other);
  }

  // implements Message ----------------------------------------------

  AppLaunchRequest* New(::PROTOBUF_NAMESPACE_ID::Arena* arena = nullptr) const final {
    return CreateMaybeMessage<AppLaunchRequest>(arena);
  }
  using ::PROTOBUF_NAMESPACE_ID::Message::CopyFrom;
  void CopyFrom(const AppLaunchRequest& from);
  using ::PROTOBUF_NAMESPACE_ID::Message::MergeFrom;
  void MergeFrom(const AppLaunchRequest& from);
  private:
  static void MergeImpl(::PROTOBUF_NAMESPACE_ID::Message* to, const ::PROTOBUF_NAMESPACE_ID::Message& from);
  public:
  PROTOBUF_ATTRIBUTE_REINITIALIZES void Clear() final;
  bool IsInitialized() const final;

  size_t ByteSizeLong() const final;
  const char* _InternalParse(const char* ptr, ::PROTOBUF_NAMESPACE_ID::internal::ParseContext* ctx) final;
  uint8_t* _InternalSerialize(
      uint8_t* target, ::PROTOBUF_NAMESPACE_ID::io::EpsCopyOutputStream* stream) const final;
  int GetCachedSize() const final { return _cached_size_.Get(); }

  private:
  void SharedCtor();
  void SharedDtor();
  void SetCachedSize(int size) const final;
  void InternalSwap(AppLaunchRequest* other);

  private:
  friend class ::PROTOBUF_NAMESPACE_ID::internal::AnyMetadata;
  static ::PROTOBUF_NAMESPACE_ID::StringPiece FullMessageName() {
    return "vm_manager.AppLaunchRequest";
  }
  protected:
  explicit AppLaunchRequest(::PROTOBUF_NAMESPACE_ID::Arena* arena,
                       bool is_message_owned = false);
  private:
  static void ArenaDtor(void* object);
  inline void RegisterArenaDtor(::PROTOBUF_NAMESPACE_ID::Arena* arena);
  public:

  static const ClassData _class_data_;
  const ::PROTOBUF_NAMESPACE_ID::Message::ClassData*GetClassData() const final;

  ::PROTOBUF_NAMESPACE_ID::Metadata GetMetadata() const final;

  // nested types ----------------------------------------------------

  // accessors -------------------------------------------------------

  enum : int {
    kAppNameFieldNumber = 1,
    kDispIdFieldNumber = 2,
  };
  // string app_name = 1;
  void clear_app_name();
  const std::string& app_name() const;
  template <typename ArgT0 = const std::string&, typename... ArgT>
  void set_app_name(ArgT0&& arg0, ArgT... args);
  std::string* mutable_app_name();
  PROTOBUF_NODISCARD std::string* release_app_name();
  void set_allocated_app_name(std::string* app_name);
  private:
  const std::string& _internal_app_name() const;
  inline PROTOBUF_ALWAYS_INLINE void _internal_set_app_name(const std::string& value);
  std::string* _internal_mutable_app_name();
  public:

  // uint32 disp_id = 2;
  void clear_disp_id();
  uint32_t disp_id() const;
  void set_disp_id(uint32_t value);
  private:
  uint32_t _internal_disp_id() const;
  void _internal_set_disp_id(uint32_t value);
  public:

  // @@protoc_insertion_point(class_scope:vm_manager.AppLaunchRequest)
 private:
  class _Internal;

  template <typename T> friend class ::PROTOBUF_NAMESPACE_ID::Arena::InternalHelper;
  typedef void InternalArenaConstructable_;
  typedef void DestructorSkippable_;
  ::PROTOBUF_NAMESPACE_ID::internal::ArenaStringPtr app_name_;
  uint32_t disp_id_;
  mutable ::PROTOBUF_NAMESPACE_ID::internal::CachedSize _cached_size_;
  friend struct ::TableStruct_vm_5fguest_2eproto;
};
// -------------------------------------------------------------------

class AppLaunchResponse final :
    public ::PROTOBUF_NAMESPACE_ID::Message /* @@protoc_insertion_point(class_definition:vm_manager.AppLaunchResponse) */ {
 public:
  inline AppLaunchResponse() : AppLaunchResponse(nullptr) {}
  ~AppLaunchResponse() override;
  explicit constexpr AppLaunchResponse(::PROTOBUF_NAMESPACE_ID::internal::ConstantInitialized);

  AppLaunchResponse(const AppLaunchResponse& from);
  AppLaunchResponse(AppLaunchResponse&& from) noexcept
    : AppLaunchResponse() {
    *this = ::std::move(from);
  }

  inline AppLaunchResponse& operator=(const AppLaunchResponse& from) {
    CopyFrom(from);
    return *this;
  }
  inline AppLaunchResponse& operator=(AppLaunchResponse&& from) noexcept {
    if (this == &from) return *this;
    if (GetOwningArena() == from.GetOwningArena()
  #ifdef PROTOBUF_FORCE_COPY_IN_MOVE
        && GetOwningArena() != nullptr
  #endif  // !PROTOBUF_FORCE_COPY_IN_MOVE
    ) {
      InternalSwap(&from);
    } else {
      CopyFrom(from);
    }
    return *this;
  }

  static const ::PROTOBUF_NAMESPACE_ID::Descriptor* descriptor() {
    return GetDescriptor();
  }
  static const ::PROTOBUF_NAMESPACE_ID::Descriptor* GetDescriptor() {
    return default_instance().GetMetadata().descriptor;
  }
  static const ::PROTOBUF_NAMESPACE_ID::Reflection* GetReflection() {
    return default_instance().GetMetadata().reflection;
  }
  static const AppLaunchResponse& default_instance() {
    return *internal_default_instance();
  }
  static inline const AppLaunchResponse* internal_default_instance() {
    return reinterpret_cast<const AppLaunchResponse*>(
               &_AppLaunchResponse_default_instance_);
  }
  static constexpr int kIndexInFileMessages =
    1;

  friend void swap(AppLaunchResponse& a, AppLaunchResponse& b) {
    a.Swap(&b);
  }
  inline void Swap(AppLaunchResponse* other) {
    if (other == this) return;
  #ifdef PROTOBUF_FORCE_COPY_IN_SWAP
    if (GetOwningArena() != nullptr &&
        GetOwningArena() == other->GetOwningArena()) {
   #else  // PROTOBUF_FORCE_COPY_IN_SWAP
    if (GetOwningArena() == other->GetOwningArena()) {
  #endif  // !PROTOBUF_FORCE_COPY_IN_SWAP
      InternalSwap(other);
    } else {
      ::PROTOBUF_NAMESPACE_ID::internal::GenericSwap(this, other);
    }
  }
  void UnsafeArenaSwap(AppLaunchResponse* other) {
    if (other == this) return;
    GOOGLE_DCHECK(GetOwningArena() == other->GetOwningArena());
    InternalSwap(other);
  }

  // implements Message ----------------------------------------------

  AppLaunchResponse* New(::PROTOBUF_NAMESPACE_ID::Arena* arena = nullptr) const final {
    return CreateMaybeMessage<AppLaunchResponse>(arena);
  }
  using ::PROTOBUF_NAMESPACE_ID::Message::CopyFrom;
  void CopyFrom(const AppLaunchResponse& from);
  using ::PROTOBUF_NAMESPACE_ID::Message::MergeFrom;
  void MergeFrom(const AppLaunchResponse& from);
  private:
  static void MergeImpl(::PROTOBUF_NAMESPACE_ID::Message* to, const ::PROTOBUF_NAMESPACE_ID::Message& from);
  public:
  PROTOBUF_ATTRIBUTE_REINITIALIZES void Clear() final;
  bool IsInitialized() const final;

  size_t ByteSizeLong() const final;
  const char* _InternalParse(const char* ptr, ::PROTOBUF_NAMESPACE_ID::internal::ParseContext* ctx) final;
  uint8_t* _InternalSerialize(
      uint8_t* target, ::PROTOBUF_NAMESPACE_ID::io::EpsCopyOutputStream* stream) const final;
  int GetCachedSize() const final { return _cached_size_.Get(); }

  private:
  void SharedCtor();
  void SharedDtor();
  void SetCachedSize(int size) const final;
  void InternalSwap(AppLaunchResponse* other);

  private:
  friend class ::PROTOBUF_NAMESPACE_ID::internal::AnyMetadata;
  static ::PROTOBUF_NAMESPACE_ID::StringPiece FullMessageName() {
    return "vm_manager.AppLaunchResponse";
  }
  protected:
  explicit AppLaunchResponse(::PROTOBUF_NAMESPACE_ID::Arena* arena,
                       bool is_message_owned = false);
  private:
  static void ArenaDtor(void* object);
  inline void RegisterArenaDtor(::PROTOBUF_NAMESPACE_ID::Arena* arena);
  public:

  static const ClassData _class_data_;
  const ::PROTOBUF_NAMESPACE_ID::Message::ClassData*GetClassData() const final;

  ::PROTOBUF_NAMESPACE_ID::Metadata GetMetadata() const final;

  // nested types ----------------------------------------------------

  // accessors -------------------------------------------------------

  enum : int {
    kStatusFieldNumber = 1,
    kCodeFieldNumber = 2,
  };
  // .vm_manager.AppStatus status = 1;
  void clear_status();
  ::vm_manager::AppStatus status() const;
  void set_status(::vm_manager::AppStatus value);
  private:
  ::vm_manager::AppStatus _internal_status() const;
  void _internal_set_status(::vm_manager::AppStatus value);
  public:

  // sint32 code = 2;
  void clear_code();
  int32_t code() const;
  void set_code(int32_t value);
  private:
  int32_t _internal_code() const;
  void _internal_set_code(int32_t value);
  public:

  // @@protoc_insertion_point(class_scope:vm_manager.AppLaunchResponse)
 private:
  class _Internal;

  template <typename T> friend class ::PROTOBUF_NAMESPACE_ID::Arena::InternalHelper;
  typedef void InternalArenaConstructable_;
  typedef void DestructorSkippable_;
  int status_;
  int32_t code_;
  mutable ::PROTOBUF_NAMESPACE_ID::internal::CachedSize _cached_size_;
  friend struct ::TableStruct_vm_5fguest_2eproto;
};
// ===================================================================


// ===================================================================

#ifdef __GNUC__
  #pragma GCC diagnostic push
  #pragma GCC diagnostic ignored "-Wstrict-aliasing"
#endif  // __GNUC__
// AppLaunchRequest

// string app_name = 1;
inline void AppLaunchRequest::clear_app_name() {
  app_name_.ClearToEmpty();
}
inline const std::string& AppLaunchRequest::app_name() const {
  // @@protoc_insertion_point(field_get:vm_manager.AppLaunchRequest.app_name)
  return _internal_app_name();
}
template <typename ArgT0, typename... ArgT>
inline PROTOBUF_ALWAYS_INLINE
void AppLaunchRequest::set_app_name(ArgT0&& arg0, ArgT... args) {
 
 app_name_.Set(::PROTOBUF_NAMESPACE_ID::internal::ArenaStringPtr::EmptyDefault{}, static_cast<ArgT0 &&>(arg0), args..., GetArenaForAllocation());
  // @@protoc_insertion_point(field_set:vm_manager.AppLaunchRequest.app_name)
}
inline std::string* AppLaunchRequest::mutable_app_name() {
  std::string* _s = _internal_mutable_app_name();
  // @@protoc_insertion_point(field_mutable:vm_manager.AppLaunchRequest.app_name)
  return _s;
}
inline const std::string& AppLaunchRequest::_internal_app_name() const {
  return app_name_.Get();
}
inline void AppLaunchRequest::_internal_set_app_name(const std::string& value) {
  
  app_name_.Set(::PROTOBUF_NAMESPACE_ID::internal::ArenaStringPtr::EmptyDefault{}, value, GetArenaForAllocation());
}
inline std::string* AppLaunchRequest::_internal_mutable_app_name() {
  
  return app_name_.Mutable(::PROTOBUF_NAMESPACE_ID::internal::ArenaStringPtr::EmptyDefault{}, GetArenaForAllocation());
}
inline std::string* AppLaunchRequest::release_app_name() {
  // @@protoc_insertion_point(field_release:vm_manager.AppLaunchRequest.app_name)
  return app_name_.Release(&::PROTOBUF_NAMESPACE_ID::internal::GetEmptyStringAlreadyInited(), GetArenaForAllocation());
}
inline void AppLaunchRequest::set_allocated_app_name(std::string* app_name) {
  if (app_name != nullptr) {
    
  } else {
    
  }
  app_name_.SetAllocated(&::PROTOBUF_NAMESPACE_ID::internal::GetEmptyStringAlreadyInited(), app_name,
      GetArenaForAllocation());
#ifdef PROTOBUF_FORCE_COPY_DEFAULT_STRING
  if (app_name_.IsDefault(&::PROTOBUF_NAMESPACE_ID::internal::GetEmptyStringAlreadyInited())) {
    app_name_.Set(&::PROTOBUF_NAMESPACE_ID::internal::GetEmptyStringAlreadyInited(), "", GetArenaForAllocation());
  }
#endif // PROTOBUF_FORCE_COPY_DEFAULT_STRING
  // @@protoc_insertion_point(field_set_allocated:vm_manager.AppLaunchRequest.app_name)
}

// uint32 disp_id = 2;
inline void AppLaunchRequest::clear_disp_id() {
  disp_id_ = 0u;
}
inline uint32_t AppLaunchRequest::_internal_disp_id() const {
  return disp_id_;
}
inline uint32_t AppLaunchRequest::disp_id() const {
  // @@protoc_insertion_point(field_get:vm_manager.AppLaunchRequest.disp_id)
  return _internal_disp_id();
}
inline void AppLaunchRequest::_internal_set_disp_id(uint32_t value) {
  
  disp_id_ = value;
}
inline void AppLaunchRequest::set_disp_id(uint32_t value) {
  _internal_set_disp_id(value);
  // @@protoc_insertion_point(field_set:vm_manager.AppLaunchRequest.disp_id)
}

// -------------------------------------------------------------------

// AppLaunchResponse

// .vm_manager.AppStatus status = 1;
inline void AppLaunchResponse::clear_status() {
  status_ = 0;
}
inline ::vm_manager::AppStatus AppLaunchResponse::_internal_status() const {
  return static_cast< ::vm_manager::AppStatus >(status_);
}
inline ::vm_manager::AppStatus AppLaunchResponse::status() const {
  // @@protoc_insertion_point(field_get:vm_manager.AppLaunchResponse.status)
  return _internal_status();
}
inline void AppLaunchResponse::_internal_set_status(::vm_manager::AppStatus value) {
  
  status_ = value;
}
inline void AppLaunchResponse::set_status(::vm_manager::AppStatus value) {
  _internal_set_status(value);
  // @@protoc_insertion_point(field_set:vm_manager.AppLaunchResponse.status)
}

// sint32 code = 2;
inline void AppLaunchResponse::clear_code() {
  code_ = 0;
}
inline int32_t AppLaunchResponse::_internal_code() const {
  return code_;
}
inline int32_t AppLaunchResponse::code() const {
  // @@protoc_insertion_point(field_get:vm_manager.AppLaunchResponse.code)
  return _internal_code();
}
inline void AppLaunchResponse::_internal_set_code(int32_t value) {
  
  code_ = value;
}
inline void AppLaunchResponse::set_code(int32_t value) {
  _internal_set_code(value);
  // @@protoc_insertion_point(field_set:vm_manager.AppLaunchResponse.code)
}

#ifdef __GNUC__
  #pragma GCC diagnostic pop
#endif  // __GNUC__
// -------------------------------------------------------------------


// @@protoc_insertion_point(namespace_scope)

}  // namespace vm_manager

PROTOBUF_NAMESPACE_OPEN

template <> struct is_proto_enum< ::vm_manager::AppStatus> : ::std::true_type {};
template <>
inline const EnumDescriptor* GetEnumDescriptor< ::vm_manager::AppStatus>() {
  return ::vm_manager::AppStatus_descriptor();
}

PROTOBUF_NAMESPACE_CLOSE

// @@protoc_insertion_point(global_scope)

#include <google/protobuf/port_undef.inc>
#endif  // GOOGLE_PROTOBUF_INCLUDED_GOOGLE_PROTOBUF_INCLUDED_vm_5fguest_2eproto
