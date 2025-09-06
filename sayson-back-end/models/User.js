import mongoose from 'mongoose';

const userSchema = new mongoose.Schema({
  firstName: String,
  lastName: String,
  age: String,
  gender: String,
  contactNumber: String,
  email: { type: String, unique: true, required: true },
  username: { type: String, unique: true, required: true },
  password: { type: String, required: true }, // hashed
  address: String,
  isActive: { type: Boolean, default: true },
  type: { type: String, default: 'user' }
}, { timestamps: true });

export default mongoose.model('User', userSchema);
