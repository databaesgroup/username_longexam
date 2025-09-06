import mongoose from 'mongoose';
const articleSchema = new mongoose.Schema({
  name: String,
  title: String,
  content: [String],
  isActive: { type: Boolean, default: true }
}, { timestamps: true });
export default mongoose.model('Article', articleSchema);
